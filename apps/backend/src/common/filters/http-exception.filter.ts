import {
  ArgumentsHost,
  Catch,
  ExceptionFilter,
  HttpException,
  HttpStatus,
  Logger,
} from '@nestjs/common';
import * as Sentry from '@sentry/node';

import { DomainError } from '../errors/domain-error';

import type { Request, Response } from 'express';

interface ProblemDocument {
  type: string;
  title: string;
  status: number;
  detail?: string;
  instance: string;
  code?: string;
  errors?: unknown;
}

@Catch()
export class HttpExceptionFilter implements ExceptionFilter {
  private readonly logger = new Logger(HttpExceptionFilter.name);

  catch(exception: unknown, host: ArgumentsHost): void {
    const http = host.switchToHttp();
    const response = http.getResponse<Response>();
    const request = http.getRequest<Request>();
    const problem = this.toProblem(exception, request.originalUrl || request.url);

    if (problem.status >= 500) {
      this.logger.error(
        `${request.method} ${problem.instance} — ${problem.title}`,
        exception instanceof Error ? exception.stack : undefined,
      );
      // SentryInterceptor captures 5xx that flow through the interceptor chain;
      // this call covers errors thrown directly inside filters or exception
      // factories that bypass the interceptor chain entirely.
      Sentry.captureException(exception);
    }

    response.status(problem.status).type('application/problem+json').send(problem);
  }

  private toProblem(exception: unknown, instance: string): ProblemDocument {
    if (exception instanceof DomainError) {
      const problem: ProblemDocument = {
        type: `urn:problem-type:${exception.code}`,
        title: exception.title,
        status: exception.status,
        instance,
        code: exception.code,
      };
      if (exception.detail !== undefined) {
        problem.detail = exception.detail;
      }
      return problem;
    }

    if (exception instanceof HttpException) {
      const status = exception.getStatus();
      const body = exception.getResponse();
      const title = this.titleFor(status);
      if (typeof body === 'string') {
        return { type: 'about:blank', title, status, detail: body, instance };
      }
      const obj = body as Record<string, unknown>;
      const problem: ProblemDocument = {
        type: 'about:blank',
        title: (obj['error'] as string | undefined) ?? title,
        status,
        instance,
      };
      if (typeof obj['message'] === 'string') {
        problem.detail = obj['message'];
      }
      if (Array.isArray(obj['message'])) {
        problem.errors = obj['message'];
      }
      return problem;
    }

    // express-openapi-validator throws BadRequest / Unauthorized / etc., which
    // carry a numeric `status` (or `statusCode`) plus a human-readable message
    // but are NOT NestJS HttpExceptions. Without this branch they fall through
    // to a generic 500 and the validator's actual diagnostic is hidden.
    if (this.isHttpLikeError(exception)) {
      const status = exception.status ?? exception.statusCode ?? 400;
      const title = this.titleFor(status);
      const problem: ProblemDocument = {
        type: 'about:blank',
        title,
        status,
        instance,
      };
      if (typeof exception.message === 'string' && exception.message.length > 0) {
        problem.detail = exception.message;
      }
      if (Array.isArray(exception.errors)) {
        problem.errors = exception.errors;
      }
      return problem;
    }

    return {
      type: 'about:blank',
      title: 'Internal Server Error',
      status: HttpStatus.INTERNAL_SERVER_ERROR,
      instance,
    };
  }

  private isHttpLikeError(
    e: unknown,
  ): e is { status?: number; statusCode?: number; message?: string; errors?: unknown[] } {
    if (typeof e !== 'object' || e === null) return false;
    const obj = e as Record<string, unknown>;
    return typeof obj['status'] === 'number' || typeof obj['statusCode'] === 'number';
  }

  private titleFor(status: number): string {
    switch (status) {
      case 400: {
        return 'Bad Request';
      }
      case 401: {
        return 'Unauthorized';
      }
      case 403: {
        return 'Forbidden';
      }
      case 404: {
        return 'Not Found';
      }
      case 409: {
        return 'Conflict';
      }
      case 422: {
        return 'Unprocessable Entity';
      }
      case 429: {
        return 'Too Many Requests';
      }
      default: {
        return status >= 500 ? 'Internal Server Error' : 'Error';
      }
    }
  }
}
