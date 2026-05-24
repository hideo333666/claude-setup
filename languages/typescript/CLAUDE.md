## TypeScript / JavaScript

### 規約
- TypeScript をデフォルトとする。`any` は他の選択肢の方が悪い場合のみ使い、
  その理由をコメントで残す。
- `require` より `import`、default export より named export を優先する。
- 型エラーを `// @ts-ignore` で握りつぶさない。型を直す・union を絞る・
  リファクタする、のいずれかで解決する。

### ツール
- リポジトリに既に存在するパッケージマネージャを使う (`pnpm-lock.yaml` →
  pnpm / `yarn.lock` → yarn / `bun.lockb` → bun / それ以外は npm)。
- eslint や prettier を独自フラグで直接叩かず、プロジェクトの
  lint/format スクリプト (`npm run lint`、`npm run format`) を使う。
- 型関連の作業を完了とする前に `npx tsc --noEmit` (またはプロジェクト
  相当のコマンド) を実行する。

### テスト
- 既存のテストフレームワーク (Vitest / Jest / Node test runner) に合わせる。
  新しいフレームワークを導入しない。
- プロジェクトが `__tests__/` や `test/` の分離ディレクトリを使って
  いない限り、`*.test.ts` は実装と同じ階層に置く。
