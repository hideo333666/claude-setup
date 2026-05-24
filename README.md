# claude-setup

`.claude/` 配下の skills・rules・settings を、共通テンプレ + 言語別オーバーレイ
として一発配布するためのセットアップリポジトリ。

新規マシンや新規プロジェクトに Claude Code 用の設定を揃えるとき、毎回手で
コピーする代わりに `curl | bash` で初期化・更新できます。

## クイックスタート

### プロジェクトに導入する (`./.claude/`)

```bash
# ベースルールのみ
curl -fsSL https://raw.githubusercontent.com/hideo333666/claude-setup/main/install.sh | bash

# TypeScript 用のオーバーレイを重ねる
curl -fsSL https://raw.githubusercontent.com/hideo333666/claude-setup/main/install.sh \
  | bash -s -- --lang typescript
```

### 個人設定として導入する (`~/.claude/`)

```bash
curl -fsSL https://raw.githubusercontent.com/hideo333666/claude-setup/main/install.sh \
  | bash -s -- --scope user
```

### ローカルクローンから実行

```bash
git clone https://github.com/hideo333666/claude-setup.git
cd claude-setup
bash install.sh --lang python --scope project --dry-run   # 差分プレビュー
bash install.sh --lang python --scope project             # 実行
```

## オプション

| Option       | 説明                                                         | デフォルト |
| ------------ | ------------------------------------------------------------ | ---------- |
| `--lang`     | `typescript` / `python` / `go` / `rust` / `react` / `nextjs` のいずれか | (なし)     |
| `--scope`    | `user` (= `~/.claude/`) / `project` (= `./.claude/`)         | `project`  |
| `--dry-run`  | 何が書き込まれるかを表示するだけで実際には書き換えない       | off        |
| `--force`    | 既存 `.claude/` のバックアップを取らずに上書き               | off        |

環境変数:

- `CLAUDE_SETUP_REPO` — clone 元 URL を上書き
- `CLAUDE_SETUP_BRANCH` — branch/tag を上書き (デフォルト `main`)
- `CLAUDE_SETUP_SRC` — ローカルチェックアウトを直接指定 (clone をスキップ)

## どうマージされるか

`install.sh` は次の順序で対象 `.claude/` に書き込みます。

1. `base/skills/**` → コピー (同名は上書き)
2. `base/CLAUDE.md` → `<!-- claude-setup:base -->` セクションとして追記
3. `base/settings.json` → 既存とディープマージ (jq ベース)
4. `--lang <x>` 指定時、`languages/<x>/` で 1〜3 を繰り返し
   (マーカー `<!-- claude-setup:lang:<x> -->` でセクション化)

同じコマンドを再実行しても結果が変わらないよう、CLAUDE.md はマーカーで
重複追記を防ぎ、settings.json は配列を unique 化したディープマージで
冪等化しています。

## 依存

- `bash`
- `jq` (settings.json のマージに使用)
- `git` (curl 経由で実行したときの自己 clone 用 / ローカル実行では不要)

macOS:

```bash
brew install jq
```

## 構成

```
claude-setup/
├── install.sh                # エントリポイント
├── base/                     # 全プロジェクト共通
│   ├── skills/
│   ├── CLAUDE.md
│   └── settings.json
├── languages/                # 言語別オーバーレイ
│   ├── typescript/
│   ├── python/
│   ├── go/
│   ├── rust/
│   ├── react/
│   └── nextjs/               # react-best-practices スキル同梱
└── scripts/
    ├── lib.sh                # 共通ヘルパ
    ├── merge-json.sh         # JSON ディープマージ
    └── apply-overlay.sh      # 1 つのオーバーレイを展開
```

## カスタマイズ

このリポジトリを fork して `base/` や `languages/<lang>/` を自分好みに
書き換え、`CLAUDE_SETUP_REPO` を自分の fork に向ければ、自分用のセット
アップとして配布できます。

新しい言語を追加するときは、`languages/<lang>/` を作って `CLAUDE.md` /
`settings.json` を置き、`install.sh` の `SUPPORTED_LANGS` 配列に名前を
追加してください。

## ライセンス

MIT。`LICENSE` ファイルを参照。
