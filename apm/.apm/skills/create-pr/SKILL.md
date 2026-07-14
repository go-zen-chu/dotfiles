---
name: create-pr
description: Create a pull request on GitHub.
---

# git と gh で PR を作成する

現在のリポジトリの状態から `git` と `gh` を使って PR を作成する。

## ゴール

デフォルトブランチとの差分がなければ何もしない。差分があれば新しいブランチ用の独立した worktree を作成し、差分から生成したデフォルトテンプレートで PR を作成する。

## 必要なツール

- `git`（`git worktree` をサポートするバージョン）
- `gh`

## 前提条件

- カレントディレクトリが git リポジトリの中であること。
- `gh auth status` が成功すること。
- `origin` が存在し、デフォルトブランチを fetch できること。
- worktree 用の一時ディレクトリを `mktemp -d` で作成できること。

## 安全のためのルール

- デフォルトブランチとの差分がなければ処理を中断する。
- 新しいブランチは必ず独立した worktree 上で作成する。ユーザーの現在の作業ツリーのブランチやファイルには一切触れない。
- ユーザーが明示的に依頼しない限り force-push しない。
- このスキルの中で PR をマージしない。
- 未コミットの変更が PR の内容に影響する場合は、進める前に確認する。
- 変更内容のスコープに合ったブランチ名を付ける。
- worktree は PR 作成の成否にかかわらず必ず `git worktree remove` で削除する。`rm -rf` で直接消さない（`.git/worktrees/` にメタデータが残る）。

## 手順

1. リポジトリの状態を確認する。

```bash
main_repo_dir="$(pwd)"
git status --short --branch
git remote -v
gh auth status
```

2. 現在のブランチとデフォルトブランチを取得する。

```bash
git branch --show-current
gh repo view --json defaultBranchRef --jq .defaultBranchRef.name
```

3. デフォルトブランチを fetch し、差分の有無を確認する。

```bash
default_branch="$(gh repo view --json defaultBranchRef --jq .defaultBranchRef.name)"
git fetch origin "$default_branch"
git diff --quiet "origin/$default_branch...HEAD"
```

- `git diff --quiet` の終了ステータスが `0` なら中断する。
- `1` なら続行する。
- それ以外なら、エラーを報告して中断する。

4. 差分を確認する。

```bash
git log --oneline "origin/$default_branch..HEAD"
git diff --stat "origin/$default_branch...HEAD"
git diff "origin/$default_branch...HEAD"
```

5. 新しいブランチ用の worktree を作成する。

- 差分のスコープから短いブランチ名を決める。`feat/<topic>`、`fix/<topic>`、`chore/<topic>` を優先する。
- worktree のディレクトリ名は `org-repo-branch-datetime` の形式にし、一意でありながら何のための worktree か一目で分かるようにする。
- `HEAD`（現在のコミット、= 確認済みの差分）を起点にブランチを作る。`origin/$default_branch` を起点にしない（差分が失われるため）。

```bash
new_branch="<new-branch-name>"
org_repo="$(gh repo view --json owner,name --jq '(.owner.login)+"-"+(.name)')"
branch_slug="$(echo "$new_branch" | tr '/' '-')"
worktree_dir="$(mktemp -d -t "${org_repo}-${branch_slug}-$(date +%Y%m%d%H%M%S).XXXXXX")"
git worktree add -b "$new_branch" "$worktree_dir" HEAD
cd "$worktree_dir"
```

6. 新しいブランチを push する（worktree 内で実行する）。

```bash
git push -u origin HEAD
```

7. 差分から PR のタイトルと本文を作成する。

- タイトルは短く、変更内容が行動として伝わるものにする。

デフォルトテンプレート:

```md
## Why / Background of this PR

- <detailed inferred intent>

## What / Changes

- <key change 1>
- <key change 2>

## Validation /QA

- <test or verification step>

## Risks

- <risk or follow-up, or "None">
```

テンプレートを埋める際のルール:

- `git diff origin/$default_branch...HEAD` の内容を根拠にする。
- `Why` が最も重要なセクションである。
- `Why` では、差分から作者の意図をできる限り深く推測する。
- `Why` では、想定される背景・解決しようとしている問題・目指すゴール・軽減したいリスクや摩擦を説明する。
- `Why` にコードの変更内容をそのまま書き写さない。
- 意図が不確かな場合は、最も妥当な解釈を、差分の根拠に基づいた範囲で述べる。
- `What` は事実ベースで簡潔に保つ。
- 実際に実行したテストを記載する。何も実行していない場合は `Not run` と書く。
- 差分が小さい場合は、各セクションを短くする。

8. `gh` で PR を作成する（worktree 内で実行する）。

```bash
gh pr create \
	--base "$default_branch" \
	--head "$(git branch --show-current)" \
	--title "<PR title>" \
	--body "<PR body>"
```

9. 依頼があれば、レビュアー・ラベル・draft 状態を追加する。

例:

```bash
gh pr create --draft --title "<PR title>" --body "<PR body>"
gh pr edit --add-reviewer reviewer1,reviewer2
gh pr edit --add-label chore
```

10. worktree を削除する。

- 手順 5〜9 のいずれかが失敗した場合でも、必ずこの手順を実行して worktree を片付ける。
- ブランチ自体は削除しない。レビュー対応で追加コミットする際に、同じブランチで worktree を作り直せるようにするため。

```bash
cd "$main_repo_dir"
git worktree remove "$worktree_dir"
```

11. 結果を報告する。

## 出力形式

結果を次の表で報告する。

| 項目 | 値 |
|---|---|
| Result | `Created` / `No-op` / `Failed` |
| PR URL | `<url>` または `-` |
| Base branch | `<default_branch>` |
| Head branch | `<new-branch-name>` |
| PR title | `<title>` |
| Summary | PR の内容を一言で説明 |

- `Result` が `No-op` の場合は、理由（例: "デフォルトブランチとの差分がない"）を `Summary` に書き、他の行は `-` にする。
- `Result` が `Failed` の場合は、失敗した手順と実際のコマンド出力を `Summary` に書く。

## 失敗時の対応

- `gh` が未認証の場合は中断し、ユーザーに `gh auth login` の実行を依頼する。
- デフォルトブランチとの差分がない場合は、PR を作成しなかった旨を報告する。
- `git worktree add` が失敗した場合（パスの衝突、ブランチ名の重複など）は、エラーを報告して中断する。
- リモートが存在しない、またはアクセス権がなく push が失敗した場合は、正確な失敗内容を報告して中断する。
- `gh pr create` が既存の PR ありと報告した場合は、新規作成せず既存の PR の URL を返す。
- ブランチ保護やリポジトリポリシーで手順がブロックされた場合は、ブロックされた手順と実際のコマンド出力を報告する。
- いずれの失敗でも、`git worktree remove` による後片付けを試みる。それも失敗する場合は `git worktree list` の結果を報告し、手動でのクリーンアップをユーザーに依頼する。
