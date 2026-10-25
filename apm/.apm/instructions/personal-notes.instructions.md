---
description: Treat the personal notes repository as permanent memory across all projects
---

依頼者の個人ノート (go-zen-chu/notes) を、全プロジェクト共通の永続的な memory として扱う。

- 依頼者の環境・方針・過去の判断に関わる話題や、記録を残す・memory に保存するよう求められたときは、まず notes の `AGENTS.md` を読み、その指示に従う
    - ローカルにあれば `~/ghq/github.com/go-zen-chu/notes/AGENTS.md`、なければ `gh api repos/go-zen-chu/notes/contents/AGENTS.md -H 'Accept: application/vnd.github.raw'`
