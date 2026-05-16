// Base64url-encoded { createdAt: ISO-8601, id: string }. Strict round-trip.
export function encodeCursor(input: { createdAt: string; id: string }): string {
  return Buffer.from(JSON.stringify(input), 'utf8').toString('base64url');
}

export function decodeCursor(input: string): { createdAt: string; id: string } {
  const raw = JSON.parse(Buffer.from(input, 'base64url').toString('utf8'));
  if (typeof raw?.createdAt !== 'string' || typeof raw?.id !== 'string') {
    throw new Error('Invalid cursor');
  }
  return raw;
}
