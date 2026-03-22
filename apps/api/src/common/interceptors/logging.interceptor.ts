import {
  Injectable,
  NestInterceptor,
  ExecutionContext,
  CallHandler,
  Logger,
} from '@nestjs/common';
import { Observable, tap } from 'rxjs';
import { Request } from 'express';

/**
 * リクエスト/レスポンスのロギングインターセプター
 *
 * 各リクエストのメソッド、URL、レスポンスタイム、ステータスコードをログに記録する。
 * CLAUDE.md の `console.log 禁止` ルールに従い、NestJS Logger を使用する。
 */
@Injectable()
export class LoggingInterceptor implements NestInterceptor {
  private readonly logger = new Logger('HTTP');

  intercept(context: ExecutionContext, next: CallHandler): Observable<unknown> {
    const request = context.switchToHttp().getRequest<Request>();
    const { method, url } = request;
    const startTime = Date.now();

    return next.handle().pipe(
      tap({
        next: () => {
          const duration = Date.now() - startTime;
          this.logger.log(`${method} ${url} - ${duration}ms`);
        },
        error: (error: Error) => {
          const duration = Date.now() - startTime;
          this.logger.warn(`${method} ${url} - ${duration}ms - ${error.message}`);
        },
      }),
    );
  }
}
