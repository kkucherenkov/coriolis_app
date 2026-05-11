/**
 * A Query is a plain data object — no methods, no dependencies. Mirrors
 * the GetMeQuery / DeleteMeCommand pattern in this module.
 */
export class ExportMeQuery {
  constructor(public readonly userId: string) {}
}
