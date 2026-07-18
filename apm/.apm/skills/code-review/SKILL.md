---
name: code-review
description: Use when reviewing code, a diff, or a pull request. Checks changes against the software design and testing conventions (general and Go) for testability, extensibility, and maintainability.
---

# Code Review

コードやコミット、プルリクエストのレビュー時に、この規約を観点として差分を確認する。
目的は、テスト容易性・拡張性・保守性の高いコードを維持し、長期的に高い品質を保つこと。

各項目の背景・根拠・詳細な補足は references/ を参照する。

- [references/software-design.md](references/software-design.md) — 一般的な設計・テスト規約の詳細
- [references/golang.md](references/golang.md) — Go 固有の設計・テスト規約の詳細

## 使い方

1. レビュー対象の差分を把握する（変更ファイル・意図・影響範囲）。
2. 下記チェックリストの観点で差分を確認する。判断に迷う項目は該当する references/ のファイルを読み、背景を確認する。
3. 指摘は「出力形式」の表にまとめる。
4. (MUST) の違反は、修正前に依頼者へ判断を求めるべき重要度として扱う。

## チェックリスト

### 一般的な設計

1. (MUST) 指示がなければ、ソースコードのコメント・出力は全て英語にする。
2. プロジェクトのイディオムを優先し、次に言語標準のイディオムに従う。
3. 疎結合・高凝集・単一責任なモジュール設計にする。
4. 標準ライブラリを優先し、外部ライブラリへの依存度を下げる。
5. I/O ロジックとビジネスロジックを分離する。
6. レイヤー・モジュール間の境界をインターフェースで明確にする。
7. インターフェースは「何をするか」を宣言的に表す。
8. (MUST) グローバルステート・暗黙的な副作用を禁止する。
9. (MUST) 依存関係はコンストラクタベースの依存性注入で明示する。
10. ディレクトリは責任ごとに整理する（usecase, infra, cmd, domain など）。
11. (MUST) 冗長なコメントを書かない。名前で処理内容を伝える。
12. (MUST) コメントは TODO・非直感的な処理・外部仕様・Why Not に限定する。
13. 変数のスコープを最小化する。
14. (MUST) 全ての関数に「何を実現するか」を示すトップレベルコメントを付ける。
15. (MUST) 標準的な linter・formatter・testing framework を採用し、CI で常時チェックする。
16. (MUST) 外部から与えられた入力を validation する。

### 一般的なテスト

1. (MUST) BDD で `If xxx given, it should yyy` の形式で振る舞いを定義する。
2. 外部接続は最小のインターフェースでモック・スタブに置換可能にする。
3. (MUST) 繰り返すテストデータの準備処理はヘルパー関数化する。
4. main から呼ばれる高レベルのエントリ関数のテストを優先する。

### Go（該当する場合）

1. (MUST) `context.Context` は第一引数で受け取り、自前で生成しない。
2. (MUST) 関数は `(result, error)` を返し、error は `fmt.Errorf` で必ず wrap する。
3. (MUST) 構造体の初期化はコンストラクタ関数（`NewXxx`）を優先する。
4. (MUST) panic は main・テスト以外で使わない。
5. (MUST) log は `log/slog` を使い、Error/Warn/Info/Debug を適切に使い分ける。
6. テーブル駆動テスト（gotests）・go-cmp・uber-go/mock・testdata/ を用いる。

詳細・背景は [references/golang.md](references/golang.md) を参照。

## 出力形式

指摘は次の表にまとめて提示する。重要度が高い順に並べる。

| 観点 | 該当箇所 | 問題点 | 推奨する修正 | 重要度 |
|---|---|---|---|---|
| 例: 依存性注入 | `foo.go:42` | `NewFoo` がグローバル変数を参照している | コンストラクタ引数で受け取る | MUST |

- 重要度は `MUST`（違反、修正前に依頼者へ判断を求める）と `SHOULD`（推奨）の2段階とする。
- 指摘がない場合も、確認した観点を一言添えて表なしで報告してよい。
