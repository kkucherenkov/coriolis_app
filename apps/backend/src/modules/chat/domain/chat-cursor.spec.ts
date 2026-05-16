import { describe, expect, it } from 'vitest';

import { decodeCursor, encodeCursor } from './chat-cursor';

describe('chat-cursor', () => {
  it('encodes and decodes a { createdAt, id } tuple losslessly', () => {
    const input = { createdAt: '2026-05-17T10:00:00.000Z', id: 'clxyz1234567890' };
    const encoded = encodeCursor(input);
    const decoded = decodeCursor(encoded);
    expect(decoded).toEqual(input);
  });

  it('rejects non-JSON base64url input', () => {
    const notJson = Buffer.from('not-json').toString('base64url');
    expect(() => decodeCursor(notJson)).toThrow();
  });

  it('rejects valid JSON that is missing required fields', () => {
    const missingId = Buffer.from(
      JSON.stringify({ createdAt: '2026-05-17T10:00:00.000Z' }),
    ).toString('base64url');
    expect(() => decodeCursor(missingId)).toThrow('Invalid cursor');

    const missingCreatedAt = Buffer.from(JSON.stringify({ id: 'clxyz1234567890' })).toString(
      'base64url',
    );
    expect(() => decodeCursor(missingCreatedAt)).toThrow('Invalid cursor');
  });
});
