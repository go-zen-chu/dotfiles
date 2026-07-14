# Go の設計・テスト規約（詳細）

[references/software-design.md](software-design.md) の一般規約に加え、Go のコードに適用する詳細版。[SKILL.md](../SKILL.md) のチェックリストの背景・根拠はここを参照する。

## 設計

1. (MUST) `context.Context` を必要とする関数では第一引数に挿入する。必ず呼び出し元から受け取り、自分で生成しない。
2. (MUST) 関数は `(result, error)` または同等の戻り値を持ち、error を適切に wrap する。wrap せずに返却することを禁止する。
3. (MUST) 構造体の初期化はコンストラクタ関数（`NewXxx`）を優先する。
4. (MUST) error の wrap には `fmt.Errorf` を利用する。
5. (MUST) panic は main 関数やテスト目的を除いて利用しない。error は必ずハンドリングし、呼び出し元でどう処理すべきかの判断を委ねる。
6. (MUST) log は標準ライブラリの `log/slog` を利用する。
7. (MUST) `log/slog` のログレベルを次のように使い分ける。
    - Error: アプリケーションに致命的な問題が発生しており、オペレーターがすぐに対応しなければならない。
    - Warn: 問題が発生しており、不具合発生時に原因のヒントとなるもの。
    - Info: 統計的な情報など、正常の範囲で稼働していることを示すログ。大量に流れ続けないよう注意する。
    - Debug: デバッグフラグ有効時のみ確認できる、詳細の挙動を示すログ。
8. プロジェクトのディレクトリ構成はユースケース駆動にする（cmd/, infra/, usecase/）。

## テスト

1. gotests（<https://github.com/cweill/gotests>）でテーブル駆動テストを定義する。
2. インスタンスの比較は go-cmp（<https://github.com/google/go-cmp>）を利用する。
3. uber-go/mock（<https://github.com/uber-go/mock>）で mock を生成する。インターフェースを定義するファイルの先頭に `//go:generate go run go.uber.org/mock/mockgen -source=$GOFILE -destination=mock_$GOFILE -package=$GOPACKAGE` を記載し、mock はインターフェースの契約テストと組み合わせる。
4. 大きなテストデータはテストファイルではなく testdata/ フォルダに格納し、テストコードから読み取る。
