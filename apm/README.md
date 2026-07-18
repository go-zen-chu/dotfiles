# apm

Personal agent context managed with [APM (Agent Package Manager)](https://github.com/microsoft/apm).

This package distributes shared instructions and skills to any APM-supported
agent runtime. `install.sh` deploys it to Claude Code at user scope
(`~/.claude`), replacing the previous `genai/` copy.

## Layout

`.apm/instructions/` holds concise, always-on MUST rules (no `applyTo`
frontmatter). `.apm/skills/` holds the full checklists, rationale, and
per-topic `references/`, loaded on demand instead of always-on.

Instructions stay concise (MUST-level rules only) so they remain cheap to keep
in context. The full checklist, SHOULD-level items, and the rationale behind
each rule live in the relevant skill's `references/` and are loaded only when
needed.

Instructions have no `applyTo` frontmatter, so APM treats them as always-on and
`apm compile --global` writes them into `~/.claude/CLAUDE.md`.

## Deploy (user scope)

```bash
# Install the CLI (Homebrew).
brew install microsoft/apm/apm

# Deploy skills and rules to ~/.claude. Relative paths are rejected at user
# scope, so pass an absolute path to this package.
apm install "$(pwd)/apm" --global --target claude

# Compile always-on instructions into ~/.claude/CLAUDE.md.
apm compile --global
```

`install.sh` runs the last two steps automatically in `setup_claude_code`.

## Deploy paths (Claude target)

- Instructions (always-on) → `~/.claude/CLAUDE.md`
- Skills → `~/.claude/skills/<name>/SKILL.md`
