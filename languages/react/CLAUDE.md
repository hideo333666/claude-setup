## React

### 規約
- 関数コンポーネント + Hooks のみ。クラスコンポーネントや旧来の
  ライフサイクルメソッドを新規に持ち込まない。
- コンポーネントは小さく純粋に保つ。デフォルトでグローバルストアに
  頼らず、まずは state のリフトアップで考える。
- コンポーネント / スタイル / テスト (`Foo.tsx` / `Foo.module.css` /
  `Foo.test.tsx`) は同じ場所に置く。プロジェクトが別レイアウトを
  強制している場合はそれに従う。
- 既にプロジェクトで使われている状態管理ライブラリ (Zustand / Redux
  Toolkit / Jotai / TanStack Query 等) を使う。新しいものを足さない。
- `useEffect` よりコンポジションを優先する。`useEffect` は本物の副作用
  (購読・手動 DOM 操作・外部システムとの同期) のみに使い、props から
  state を派生させる用途には使わない。
- Hooks のルール (安定した識別子・条件分岐内で呼ばない・依存配列を
  網羅) を守る。

### ツール
- バンドラを自動判定する。`vite.config.*` → Vite / `next.config.*` →
  Next.js / それ以外は CRA。既存のものに合わせる。
- リポジトリに存在するパッケージマネージャを使う (`pnpm-lock.yaml` →
  pnpm / `yarn.lock` → yarn / `bun.lockb` → bun / それ以外は npm)。
- eslint / prettier を独自フラグで叩かず、プロジェクトの lint/format
  スクリプトを使う。
- 型関連の作業を完了とする前に `npx tsc --noEmit` (または相当のコマンド)
  を実行する。

### テスト
- React Testing Library + プロジェクトのランナー (Vitest / Jest) を使う。
  Enzyme は新規に導入しない。
- `data-testid` ではなく、role / label / text でクエリする。
  セマンティックな代替が無い場合のみ `data-testid` を許容する。
- コンポーネントツリー全体のスナップショットを取らない。挙動を
  アサートする。
