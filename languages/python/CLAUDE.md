## Python

### 規約
- `pyproject.toml` / `.python-version` / `setup.cfg` で宣言された
  Python バージョンを対象にする。最新版を勝手に前提にしない。
- 新規関数には型ヒントを付ける。関係のない PR で既存コードに型ヒントを
  後付けしない。
- 新規コードでは `os.path` より `pathlib.Path` を優先する。
- f-string を使う。ファイル全体が `%` フォーマットや `str.format` で
  統一されていない限り、それらを混ぜない。

### ツール
- パッケージマネージャを自動判定する。`uv.lock` → uv / `poetry.lock` →
  poetry / `Pipfile.lock` → pipenv / それ以外は pip + venv。既存のものに
  合わせる。
- プロジェクトの linter (`ruff` / `flake8`) と formatter (`ruff format` /
  `black`) を使う。途中でツールを切り替えない。
- 完了とする前にプロジェクトが使っている `ruff check` / `mypy` を実行する。

### テスト
- プロジェクトが pytest を使っているなら pytest を使う。それ以外は
  既存のフレームワークに合わせる。
- 実体で実行可能なもの (ファイル I/O・サブプロセス・インプロセス DB) を
  モックしない。モックはネットワーク境界のみ。
