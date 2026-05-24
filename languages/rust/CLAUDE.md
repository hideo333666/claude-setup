## Rust

### 規約
- `Cargo.toml` の edition に合わせる。ついでに上げない。
- エラー伝播は `match` より `?` を優先する。`thiserror` / `anyhow` は、
  既にクレートが依存している場合のみ使う。
- `unsafe` を追加するときは、必ずその根拠を `// Safety:` コメントで残す。
- `cargo clippy --all-targets -- -D warnings` 基準を守る。新しい clippy
  警告を増やさない。

### ツール
- 完了とする前に `cargo check` (または `cargo build`) と `cargo clippy`
  を実行する。
- `cargo fmt` のフォーマットに従う。関係のないファイルを再フォーマット
  しない。
- ワークスペースに `Justfile` / `Makefile` があれば、そのレシピを優先する。

### テスト
- 単体テストは同じファイル内の `#[cfg(test)] mod tests` に置く。
- 結合テストは `tests/` に置く。作業中にあちこち移動させない。
- 完了とする前に対象クレートの `cargo test` を実行する。
