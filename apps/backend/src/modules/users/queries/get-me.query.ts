/**
 * A Query is a plain data object — no methods, no dependencies.
 * It carries the authenticated user's id from the controller to the handler.
 */
export class GetMeQuery {
  constructor(public readonly userId: string) {}
}
