---
name: issue-implement
description: GitHub (gh CLI) で既存 issue を起点に、着手→ブランチ作成→実装→PR 作成まで進めるワークフロー。issue に着手・実装するとき、issue 番号を起点に作業を始めるとき、issue に紐づく PR を作るとき、「この issue やって / 着手して」と言われたときに発火する。
license: MIT
metadata:
  author: hideo333666
  version: "1.0.0"
---

# Issue 実装 (着手〜PR 作成 / GitHub)

GitHub の `gh` CLI を前提に、既存 issue を起点として **着手・実装・PR 作成** まで
一貫して進める手順。issue の受け入れ条件を起点にし、`base/CLAUDE.md` のコード
ルールに沿って実装する。

> 関連: まだ issue が無い場合は先に `issue-create` skill で起票する。

## 適用する場面

- 既存 issue に着手して実装まで進めたいとき
- issue 番号を起点にブランチ・PR を作りたいとき

## 手順

### 1. issue を読み込む

```bash
gh issue view <N> --comments
```

- 受け入れ条件・背景・コメントでの追加要件を把握する。
- 受け入れ条件が曖昧・不足していれば、実装前にユーザーへ確認する。

### 2. ブランチを作成する

- ベースブランチ (通常 `main`) を最新化してから切る。
- 命名規約: `<type>/<issue番号>-<短い説明>`
  - type は `feat` / `fix` / `chore` / `docs` / `refactor` 等。
  - 例: `feat/123-password-reset-link`

  ```bash
  git switch main && git pull
  git switch -c feat/123-password-reset-link
  ```

### 3. 計画する

- 受け入れ条件をタスクに分解する。
- 既存の実装・ユーティリティ・パターンを先に探し、再利用できないか検討する
  (`base/CLAUDE.md`: 新規ファイルを作る前に既存編集で済まないか検討)。

### 4. 実装する

- `base/CLAUDE.md` および導入言語の規約に従う:
  - 現タスクに不要な抽象化・ヘルパー・フラグを足さない。
  - コメントは「なぜ」を書く。挙動の言い換えコメントは書かない。
- `make` / `npm run` / `just` などプロジェクト固有スクリプトをアドホックコマンドより優先する。
- 完了とする前に lint / type check / test を実行する (プロジェクトのスクリプト経由)。

### 5. コミットする

- 受け入れ条件の単位で意味のあるコミットに分ける。
- メッセージは要約 + 必要なら本文。本文に `Refs #<N>` で issue を参照する。
- `--no-verify` で commit hook をスキップしない (明示依頼がある場合を除く)。
- 破壊的 git 操作 (`reset --hard` / `push --force` 等) を確認なしに実行しない。

### 6. PR を作成する

- **PR 作成は外部公開アクション**。タイトルと本文をユーザーに提示し、確認を取ってから作成する。
- 本文に `Closes #<N>` を入れて issue を自動クローズ連携させる。
- 受け入れ条件のチェックリストを本文に反映し、満たした項目をチェックする。

  ```bash
  git push -u origin feat/123-password-reset-link
  gh pr create \
    --base main \
    --title "feat: ログイン画面にパスワード再設定リンクを追加" \
    --body-file /tmp/pr-body.md
  ```

  PR 本文例:

  ```markdown
  ## 概要
  <何を・なぜ変えたか>

  Closes #123

  ## 受け入れ条件
  - [x] パスワード再設定リンクを表示する
  - [x] リンクから再設定フローに遷移する

  ## 確認方法
  - <動作確認手順 / 実行したテスト>
  ```

### 7. セルフレビュー

- `git diff main...HEAD` で差分を見直す。
- 受け入れ条件をすべて満たしているか、デバッグ用コードやコメントアウトが残っていないか確認する。
- 作成後、PR の URL をユーザーに伝える。

## 注意

- PR 本文・コミットメッセージに **シークレット・認証情報・個人情報 (PII)** を含めない。
