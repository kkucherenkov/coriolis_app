import { Injectable, Logger, NestMiddleware } from '@nestjs/common';

import type { NextFunction, Request, Response } from 'express';

const REQUEST_ID_HEADER = 'x-request-id';

/**
 * HttpLoggerMiddleware — single line per request with method, path, status,
 * duration, request id, request-body presence, and response Content-Length.
 *
 * Mounted before route resolution by ObservabilityModule. Body content is
 * never logged — only its presence/size — so we don't leak credentials.
 */
@Injectable()
export class HttpLoggerMiddleware implements NestMiddleware {
  private readonly logger = new Logger('HTTP');

  use(req: Request, res: Response, next: NextFunction): void {
    const start = process.hrtime.bigint();
    const method = req.method;
    const url = req.originalUrl;
    const reqLen = req.headers['content-length'] ?? '0';
    const bodyParsed = req.body !== undefined && req.body !== null;

    res.on('finish', () => {
      const durationMs = Number(process.hrtime.bigint() - start) / 1_000_000;
      const status = res.statusCode;
      const resLen = res.getHeader('content-length') ?? '-';
      const reqId = (req.headers[REQUEST_ID_HEADER] as string | undefined) ?? '-';
      const flag = `body=${bodyParsed ? 'yes' : 'no'}/${reqLen}b`;
      const line = `${method} ${url} ${String(status)} ${durationMs.toFixed(1)}ms req=${reqId} ${flag} res=${String(resLen)}b`;
      if (status >= 500) this.logger.error(line);
      else if (status >= 400) this.logger.warn(line);
      else this.logger.log(line);
    });

    next();
  }
}
