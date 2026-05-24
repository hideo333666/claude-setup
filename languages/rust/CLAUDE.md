## Rust

### Conventions
- Match the edition in `Cargo.toml`. Don't bump it as a side-effect.
- Prefer `?` over `match` for error propagation. Use `thiserror` /
  `anyhow` only if the crate already depends on it.
- Don't add `unsafe` without a `// Safety:` comment that justifies it.
- Use `cargo clippy --all-targets -- -D warnings` standards: don't
  introduce new clippy warnings.

### Tooling
- Run `cargo check` (or `cargo build`) and `cargo clippy` before declaring
  the change done.
- Use `cargo fmt` formatting. Don't reformat unrelated files.
- If a workspace `Justfile` / `Makefile` exists, prefer its recipes.

### Testing
- Use `#[cfg(test)] mod tests` in the same file for unit tests.
- Integration tests go in `tests/`. Don't move them mid-task.
- Run `cargo test` for the crate under change before finishing.
