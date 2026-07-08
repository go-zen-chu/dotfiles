# apm

Personal agent context managed with [APM (Agent Package Manager)](https://github.com/microsoft/apm).

This package distributes shared instructions and skills to any APM-supported
agent runtime. `install.sh` deploys it to Claude Code at user scope
(`~/.claude`), replacing the previous `genai/` copy.

## Layout

```
apm/
├── apm.yml                 # producer manifest (includes: auto)
└── .apm/
    ├── instructions/       # concise, always-on rules (no applyTo)
    │   ├── software-design.instructions.md
    │   ├── go.instructions.md
    │   └── answer-accurately.instructions.md
    └── skills/
        └── code-review/    # detailed coding conventions, loaded on demand
            └── SKILL.md
```

Instructions stay concise so they remain cheap to keep in context. The concrete,
detailed coding conventions live in the `code-review` skill and are loaded only
when a review is needed.

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
