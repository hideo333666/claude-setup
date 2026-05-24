## React

### 規約
- 関数コンポーネント + Hooks のみ。クラスコンポーネントや旧来の
  ライフサイクルメソッドを新規に持ち込まない。
- コンポーネントは小さく純粋に保つ。デフォルトでグローバルストアに
  頼らず、まずは state のリフトアップで考える。
- コンポーネント / スタイル / テストは同じ場所に置く。プロジェクトが
  別レイアウトを強制している場合はそれに従う。
- 既にプロジェクトで使われている状態管理ライブラリ (Zustand / Redux
  Toolkit / Jotai / TanStack Query 等) を使う。新しいものを足さない。
- `useEffect` よりコンポジションを優先する。`useEffect` は本物の副作用
  のみに使い、props から state を派生させる用途には使わない。
- Hooks のルール (安定した識別子・条件分岐内で呼ばない・依存配列を
  網羅) を守る。

### テスト (React)
- React Testing Library + Vitest または Jest を使う。Enzyme は新規に
  導入しない。
- `data-testid` ではなく、role / label / text でクエリする。
- コンポーネントツリー全体のスナップショットを取らない。挙動を
  アサートする。

## Next.js

### 規約
- ルーター方式を自動判定する。`app/` ディレクトリがあれば App Router、
  `pages/` があれば Pages Router。既存のものに合わせ、明示的な依頼が
  ない限りルーターを移行しない。
- App Router では Server Components がデフォルト。`"use client"` は
  本当にクライアント機能 (state / 副作用 / ブラウザ API /
  イベントハンドラ) が必要なときだけ付ける。
- データ取得は消費する場所の近くに置く (Server Component の `fetch` /
  Route Handler / Server Action)。サーバ取得のためだけにクライアント
  側のデータレイヤを持ち込まない。
- ファイルベースルーティングの名前はフレームワーク契約の一部。
  `page.tsx` / `layout.tsx` / `loading.tsx` / `error.tsx` / `route.ts` /
  `middleware.ts` をリネームしない。
- 内部ナビゲーションと画像は素の `<a>` / `<img>` ではなく `next/link` /
  `next/image` を使う。
- env 変数の分離を尊重する。`NEXT_PUBLIC_*` のみブラウザに渡り、
  それ以外はサーバ専用。Client Component からサーバシークレットを
  読まない。
- App Router のキャッシュ指定 (`fetch` のキャッシュオプション /
  `revalidate` / `dynamic`) は意図を持って使う。キャッシュ由来の
  不具合を黙らせるために `force-dynamic` を振りまかず、根本原因を
  特定する。

### ツール
- `next dev` / `next build` / `next start` はプロジェクトの npm
  スクリプト経由で実行する。
- 完了とする前に `next lint` (またはプロジェクトの lint スクリプト) と
  `npx tsc --noEmit` を実行する。

### テスト (Next.js)
- 単体 / コンポーネント: Vitest または Jest + React Testing Library。
- E2E: 既に Playwright があるならそれを使う。隣に Cypress を追加しない。
- Server Component で `fetch` をモックしない。実テストバックエンドか、
  本当に必要なときだけ MSW を使う。

### パフォーマンス参考資料
- `.claude/skills/vercel-react-best-practices/` に Vercel Engineering の
  React / Next.js パフォーマンス最適化ルール集 (70 ルール / 8 カテゴリ /
  MIT ライセンス) が同梱されています。バンドルサイズ削減・データ
  ウォーターフォール解消・Server Component 最適化・再レンダリング
  抑制などの具体的なレシピが必要なときに `SKILL.md` から該当
  カテゴリの `rules/*.md` を参照してください。
- 散文・コード内コメント・frontmatter の翻訳対象値はすべて日本語化済み
  (コード自体・API 名・kebab-case ルール ID は原文維持)。翻訳ベース
  commit と上流追従手順は
  `skills/vercel-react-best-practices/_translation_notice.md` を、
  訳語統一表は `_translation_glossary.md` を参照してください。
- `AGENTS.md` は上流の build スクリプトで `rules/*.md` から自動生成
  されるドキュメントのため、英語のまま残しています (翻訳しても
  上流の再生成で上書きされる)。
