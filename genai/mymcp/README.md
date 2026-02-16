# mymcp

Local MCP server (stdio) with a small set of tools.

## Tools

- `git_create_pr_from_default`
  - Creates a GitHub Pull Request using `git` + `gh`, based on commits ahead of the repository default branch.

## Run

```sh
cd genai/mymcp

go run .
```

## Example (tool call intent)

This server is meant to be used by an MCP-capable client.
The tool accepts these arguments:

- `repoPath` (optional)
- `base` (optional)
- `head` (optional)
- `title` (optional)
- `body` (optional)
- `draft` (optional, default `false`)
- `push` (optional, default `true`)

Notes:
- Requires `gh auth login` and a git remote named `origin`.
