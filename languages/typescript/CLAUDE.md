## TypeScript / JavaScript

### Conventions
- TypeScript is the default; reach for `any` only when the alternative is
  worse, and explain why in a comment.
- Prefer `import` over `require` and named exports over default exports.
- Don't add `// @ts-ignore` to silence errors — fix the type, narrow the
  union, or refactor.

### Tooling
- Use the package manager already present in the repo (`pnpm-lock.yaml` →
  pnpm, `yarn.lock` → yarn, `bun.lockb` → bun, otherwise npm).
- Use the project's lint/format scripts (`npm run lint`, `npm run format`)
  rather than invoking eslint/prettier directly with custom flags.
- Run `npx tsc --noEmit` (or the project's equivalent) before declaring
  type-related work done.

### Testing
- Match the existing test framework (Vitest, Jest, Node test runner).
  Don't introduce a new one.
- Co-locate `*.test.ts` next to the implementation unless the project
  already uses a separate `__tests__/` or `test/` directory.
