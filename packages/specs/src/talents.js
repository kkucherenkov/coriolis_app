// WHY this file exists:
// packages/specs is an "type":"module" package whose index.ts re-exports
// from './talents.js' (TypeScript ESM convention: write .js, tsc resolves .ts).
// When Node v24 runs the compiled backend at runtime it loads @app/specs via
// node_modules symlink → packages/specs/src/index.ts → tries to resolve
// './talents.js' and needs this file to exist.
// Node v24 with built-in strip-types support can import the .ts source directly.
export * from './talents.ts';
