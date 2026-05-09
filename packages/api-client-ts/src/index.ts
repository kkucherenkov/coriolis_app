/**
 * Generated client entry point. DO NOT EDIT BY HAND — regenerate with:
 *
 *   pnpm spec:codegen
 *
 * All exports live under `./generated` and are produced by
 * `@hey-api/openapi-ts` from `packages/specs/dist/openapi.json`.
 */

export * from './generated/index.js';
export * from './realtime/channels.js';

// Re-export the SDK client singleton so apps can apply runtime config
// (baseUrl, credentials, fetch override) at boot. The generated barrel
// only exposes operation functions and types; the client itself lives in
// `client.gen.ts` and is forwarded here without modifying generated code.
export { client } from './generated/client.gen.js';

