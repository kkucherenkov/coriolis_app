// WHY this file exists:
// Companion to starter-kits.ts — see talents.js for the full explanation.
// packages/specs is an "type":"module" package whose index.ts re-exports
// from './starter-kits.js'; Node v24 needs this stub to resolve the import
// at runtime (it then strip-types the .ts source).
export * from './starter-kits.ts';
