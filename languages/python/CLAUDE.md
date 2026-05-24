## Python

### Conventions
- Target the Python version declared in `pyproject.toml` /
  `.python-version` / `setup.cfg`. Don't assume the latest.
- Type-hint new functions. Don't add type hints to legacy modules in
  unrelated PRs.
- Prefer `pathlib.Path` over `os.path` for new code.
- Use f-strings; don't introduce `%`-formatting or `str.format` unless
  the file already uses one consistently.

### Tooling
- Detect the package manager: `uv.lock` → uv, `poetry.lock` → poetry,
  `Pipfile.lock` → pipenv, otherwise pip + venv. Match what's present.
- Use the project's linter (`ruff`, `flake8`) and formatter (`ruff format`,
  `black`) — don't switch tools mid-project.
- Run `ruff check` / `mypy` (whichever the project uses) before declaring
  the change done.

### Testing
- Use pytest if the project uses it; otherwise the project's framework.
- Don't mock what you can run for real in tests (file I/O, subprocess,
  in-process databases). Mock at network boundaries.
