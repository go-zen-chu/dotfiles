---
name: create-pr
description: Create a pull request on GitHub.
---

# Create PR with git and gh

Create a PR from the current repo state with `git` and `gh`.

## Goal

If there is no diff from the default branch, do nothing. If there is a diff, create a new branch, check it out, and create a PR using a default template generated from the diff.

## Required tools

- `git`
- `gh`

## Preconditions

- The current directory is inside a git repository.
- `gh auth status` succeeds.
- `origin` exists and the default branch can be fetched.
- The working tree can be moved to a new branch.

## Safety rules

- If there is no diff from the default branch, stop.
- Always create a new branch before creating the PR.
- Never force-push unless the user explicitly asks for it.
- Never merge the PR as part of this skill.
- If uncommitted changes affect the PR content, ask before proceeding.
- Create a branch name that matches the change scope.

## Workflow

1. Check repository state.

```bash
git status --short --branch
git remote -v
gh auth status
```

2. Read the current and default branch.

```bash
git branch --show-current
gh repo view --json defaultBranchRef --jq .defaultBranchRef.name
```

3. Fetch the default branch and check for diff.

```bash
default_branch="$(gh repo view --json defaultBranchRef --jq .defaultBranchRef.name)"
git fetch origin "$default_branch"
git diff --quiet "origin/$default_branch...HEAD"
```

- If `git diff --quiet` exits with status `0`, stop.
- If it exits with status `1`, continue.
- If it exits with any other status, report the error and stop.

4. Review the diff.

```bash
git log --oneline "origin/$default_branch..HEAD"
git diff --stat "origin/$default_branch...HEAD"
git diff "origin/$default_branch...HEAD"
```

5. Create and check out a new branch.

- Derive a short branch name from the diff scope.
- Prefer `feat/<topic>`, `fix/<topic>`, or `chore/<topic>`.

```bash
git switch -c "<new-branch-name>"
```

6. Push the new branch.

```bash
git push -u origin HEAD
```

7. Draft the PR title and body from the diff.

- Title should be short and action-oriented.

Default template:

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

Rules for filling the template:

- Base the content on `git diff origin/$default_branch...HEAD`.
- `Why` is the most important section.
- In `Why`, infer the author's intent from the diff as deeply as possible.
- In `Why`, explain the likely background, problem being addressed, desired outcome, and what risk or friction this change is trying to reduce.
- Do not just restate code changes in `Why`.
- If intent is uncertain, state the most plausible interpretation and keep it grounded in the diff.
- Keep `What` factual and concise.
- Mention tests actually run. If none were run, say `Not run`.
- If the diff is small, keep each section short.

8. Create the pull request with `gh`.

```bash
gh pr create \
	--base "$default_branch" \
	--head "$(git branch --show-current)" \
	--title "<PR title>" \
	--body "<PR body>"
```

9. Add reviewers, labels, or draft status if requested.

Examples:

```bash
gh pr create --draft --title "<PR title>" --body "<PR body>"
gh pr edit --add-reviewer reviewer1,reviewer2
gh pr edit --add-label chore
```

10. Return the result.

## Output format

Return:

- no-op result when there is no diff
- PR URL
- base branch
- head branch
- PR title
- concise summary

## Failure handling

- If `gh` is not authenticated, stop and ask the user to run `gh auth login`.
- If there is no diff against the default branch, return that no PR was created.
- If push fails because the remote does not exist or access is denied, report the exact failure and stop.
- If `gh pr create` reports that a PR already exists, return the existing PR URL instead of creating another one.
- If branch protection or repository policy blocks the workflow, report the blocking step and the exact command output.

