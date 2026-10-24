---
description: Treat the personal notes repository as permanent memory across all projects
---

<https://github.com/go-zen-chu/notes> (local: `~/ghq/github.com/go-zen-chu/notes`, private) を、全プロジェクト共通の永続的な memory として扱う。

- 依頼者の環境・方針・過去の判断に関わる話題では、まず notes を参照する（例: 開発環境とセキュリティ方針は `個人開発環境.md`）
- 記録を残す・memory に保存するよう求められたら、notes に記録する
- notes の正本は GitHub issue である。issue を `completed` で close すると issue2md workflow が markdown を生成し、main に commit する。markdown を直接編集しない
    - 新規: `gh issue create -R go-zen-chu/notes --label ...` の後に `gh issue close <url> --reason completed`
    - 追記: issue を reopen → body を編集 → `completed` で close し直す
- 時系列の記録は、`## YYYY-MM-DD <内容>` の見出しで追記する
