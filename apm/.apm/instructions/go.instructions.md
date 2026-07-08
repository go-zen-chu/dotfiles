---
description: Go-specific design and testing conventions
---

# Go の設計・テスト規約

詳細と背景は `code-review` skill を参照する。

## 設計

- (MUST) `context.Context` を要する関数は第一引数で受け取る。自前で生成せず呼び出し元から渡す。
- (MUST) 関数は `(result, error)` を返し、error は `fmt.Errorf` で必ず wrap する。
- (MUST) 構造体の初期化はコンストラクタ関数（`NewXxx`）を優先する。
- (MUST) panic は main・テスト以外で使わない。error は必ずハンドリングし、処理の判断を呼び出し元へ委ねる。
- (MUST) ログは `log/slog` を使い、Error / Warn / Info / Debug を適切に使い分ける。
- ディレクトリはユースケース駆動の構成にする（cmd/, infra/, usecase/）。

## テスト

- テーブル駆動テストを定義する（gotests）。
- インスタンスの比較は google/go-cmp を使う。
- mock は uber-go/mock で生成する。インターフェース定義ファイルの先頭に `//go:generate go run go.uber.org/mock/mockgen -source=$GOFILE -destination=mock_$GOFILE -package=$GOPACKAGE` を記載する。
- 大きなテストデータは testdata/ に置き、テストコードから読み取る。
