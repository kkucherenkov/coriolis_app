import { MiddlewareConsumer, Module, NestModule } from '@nestjs/common';

import { HttpLoggerMiddleware } from './http-logger.middleware';
import { RequestIdMiddleware } from './request-id.middleware';

@Module({
  providers: [RequestIdMiddleware, HttpLoggerMiddleware],
  exports: [RequestIdMiddleware, HttpLoggerMiddleware],
})
export class ObservabilityModule implements NestModule {
  configure(consumer: MiddlewareConsumer): void {
    // Order matters: request-id must run first so the logger can stamp it
    // onto each line.
    consumer.apply(RequestIdMiddleware, HttpLoggerMiddleware).forRoutes('*');
  }
}
