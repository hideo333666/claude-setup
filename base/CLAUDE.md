# Project Rules (base)

This file is installed by [claude-setup](https://github.com/REPLACE_ME/claude-setup).
The `base` section applies to every project. Language-specific sections may be
appended below by `install.sh --lang <name>`.

## Communication

- Match the user's language (English or 日本語).
- Be concise. Default to short answers; expand only when asked.
- When proposing a non-trivial change, surface the tradeoff in one sentence
  before implementing.

## Code

- Prefer editing existing files over creating new ones.
- Don't introduce abstractions, helpers, or feature flags that the current
  task doesn't require.
- Don't add comments that restate what the code does. Only write comments
  for non-obvious WHY (invariants, workarounds, hidden constraints).
- Don't add error handling for cases that cannot occur. Only validate at
  trust boundaries (user input, external APIs).
- If a change deletes code, actually delete it — don't leave "removed: ..."
  comments or commented-out blocks.

## Tooling

- Use the project's own scripts (`make`, `npm run`, `just`, etc.) over
  ad-hoc commands when they exist.
- Never bypass commit hooks (`--no-verify`) unless the user asks for it.
- Don't run destructive git operations (`reset --hard`, `push --force`,
  `branch -D`) without explicit confirmation.

## Secrets

- Never commit secrets, tokens, or credentials. If a file matches
  `.env*`, `*credentials*`, `*secret*`, ask before staging.
