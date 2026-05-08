/**
 * WHY this file exists:
 * Domain errors for the sharing bounded context. HttpExceptionFilter maps
 * them to RFC 9457 application/problem+json. Clients key off `code` for
 * i18n and retry logic.
 *
 * 410 Gone is used for both revoked and expired links — the slug existed
 * but access is no longer valid. This distinguishes from 404 (never existed).
 */
import { DomainError } from '../../../common/errors/domain-error';

export class ShareLinkNotFoundError extends DomainError {
  constructor(slug: string) {
    super({
      code: 'SHARE_LINK_NOT_FOUND',
      status: 404,
      title: 'Not Found',
      detail: `Share link ${slug} does not exist.`,
    });
  }
}

export class ShareLinkRevokedError extends DomainError {
  constructor(slug: string) {
    super({
      code: 'SHARE_LINK_REVOKED',
      status: 410,
      title: 'Gone',
      detail: `Share link ${slug} has been revoked.`,
    });
  }
}

export class ShareLinkExpiredError extends DomainError {
  constructor(slug: string) {
    super({
      code: 'SHARE_LINK_EXPIRED',
      status: 410,
      title: 'Gone',
      detail: `Share link ${slug} has expired.`,
    });
  }
}

export class ShareLinkNotOwnedError extends DomainError {
  constructor(id: string) {
    super({
      code: 'SHARE_LINK_NOT_OWNED',
      status: 403,
      title: 'Forbidden',
      detail: `You do not own share link ${id}.`,
    });
  }
}
