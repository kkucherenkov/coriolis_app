/**
 * WHY this file exists:
 * Domain errors for the chat bounded context. Each maps to an
 * RFC 9457 problem+json via HttpExceptionFilter.
 *
 * Codes are namespaced under CHAT_*; clients key off `code` for i18n
 * and retry logic. ChatTargetBlockedError deliberately uses a generic
 * detail string to avoid leaking which party initiated the block.
 */
import { DomainError } from '../../../common/errors/domain-error';

export class ChatMessageNotFoundError extends DomainError {
  constructor() {
    super({
      code: 'CHAT_MESSAGE_NOT_FOUND',
      status: 404,
      title: 'Chat Message Not Found',
      detail: 'The requested chat message does not exist or is not visible to you.',
    });
  }
}

export class ChatMessageNotAuthorizedError extends DomainError {
  constructor() {
    super({
      code: 'CHAT_MESSAGE_NOT_AUTHORIZED',
      status: 403,
      title: 'Forbidden',
      detail: 'Caller may not perform this action on this chat message.',
    });
  }
}

export class ChatEditWindowExpiredError extends DomainError {
  constructor() {
    super({
      code: 'CHAT_EDIT_WINDOW_EXPIRED',
      status: 422,
      title: 'Edit Window Expired',
      detail: 'The edit window for this message has passed.',
    });
  }
}

export class ChatBodyEmptyError extends DomainError {
  constructor() {
    super({
      code: 'CHAT_BODY_EMPTY',
      status: 422,
      title: 'Message Body Empty',
      detail: 'Message body must not be empty.',
    });
  }
}

export class ChatBodyTooLargeError extends DomainError {
  constructor() {
    super({
      code: 'CHAT_BODY_TOO_LARGE',
      status: 413,
      title: 'Message Body Too Large',
      detail: 'Message body exceeds the maximum allowed size.',
    });
  }
}

export class ChatTargetNotMemberError extends DomainError {
  constructor() {
    super({
      code: 'CHAT_TARGET_NOT_MEMBER',
      status: 404,
      title: 'Target Not Member',
      detail: 'The specified target membership does not exist in this session.',
    });
  }
}

export class ChatTargetBlockedError extends DomainError {
  constructor() {
    super({
      code: 'CHAT_TARGET_BLOCKED',
      status: 403,
      title: 'Forbidden',
      detail: 'This member is not accepting messages right now.',
    });
  }
}

export class ChatRateLimitedError extends DomainError {
  constructor() {
    super({
      code: 'CHAT_RATE_LIMITED',
      status: 429,
      title: 'Too Many Requests',
      detail: 'You are sending messages too fast. Please slow down.',
    });
  }
}

export class ChatNotMemberError extends DomainError {
  constructor() {
    super({
      code: 'CHAT_NOT_MEMBER',
      status: 403,
      title: 'Forbidden',
      detail: 'Caller is not an active member of this session.',
    });
  }
}
