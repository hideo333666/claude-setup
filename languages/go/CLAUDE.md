## Go

### Conventions
- Match the Go version in `go.mod`. Don't bump it as a side-effect.
- Errors are values: wrap with `fmt.Errorf("...: %w", err)` and check
  with `errors.Is` / `errors.As`. Don't introduce a custom error package
  unless one already exists.
- Use `any` (Go 1.18+) over `interface{}` for new code if the module's
  Go version allows.
- Don't add interfaces for types with a single implementation.

### Tooling
- Run `go build ./...` and `go vet ./...` before declaring the change done.
- Use `gofmt` / `goimports` formatting. Don't reformat unrelated files.
- If the repo has a `Makefile`, prefer `make test` / `make lint` over
  invoking `go test` directly.

### Testing
- Use the standard `testing` package and table-driven tests.
- Only add `testify` / other helpers if the repo already uses them.
- Run `go test ./...` (or the package under change) before finishing.
