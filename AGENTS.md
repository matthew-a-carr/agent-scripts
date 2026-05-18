# AGENTS.md

Owner: Matt.
Work style: telegraph; noun-phrases ok; drop grammar; min tokens.

## What this repo is
- Personal agent config + a publishable Claude Code / Codex / cross-agent skills marketplace.
- Plugin scope: `skills/` only. Manifests in `.claude-plugin/`.
- See `README.md` for install/distribution details.

## Skills (P0)
- Every skill follows the [agentskills.io](https://agentskills.io) open spec.
- Layout: `skills/<name>/SKILL.md` + optional `references/`, `scripts/`, `assets/` subdirs.
- Root of a skill dir contains only `SKILL.md`. Supplementary docs go in `references/`.
- Frontmatter: `name` (≤64 chars, kebab-case, must match dir name) + `description` (≤1024 chars; write to self-activate, e.g. "Use when user wants to …").
- Internal links use relative paths; cross-skill refs use `../<other-skill>/…`.
- After edits, run a quick validation pass (frontmatter present, name matches dir, links resolve).

## Naming (P0)
- Skill dir + frontmatter `name`: kebab-case, lowercase, no underscores.
- File names inside a skill: kebab-case for prose docs (e.g. `interface-design.md`), SCREAMING-KEBAB for short canonical reference docs (e.g. `LANGUAGE.md`, `ADR-FORMAT.md`) — match whatever the skill already uses.
- Conventional Commits everywhere: `feat|fix|refactor|build|ci|chore|docs|style|perf|test`. Scope = skill name when changes are scoped to one skill (e.g. `feat(tdd): …`).

## Style (P0)
- Replies: telegraph; noun phrases OK; drop filler; minimal tokens. No "AI slop".
- Markdown: match existing style of the touched file.
- Skills: imperative voice, concise sections, examples over abstractions.

## PRs (P0)
- Open as draft; mark ready only when title + description match the work.
- Title: Conventional Commits.
- Description: prioritised bullets, one item per line, no blank lines.
- "What's being changed?" list uses numeric format `1.` `2.` `3.` (not `1)`).

## Git (P0)
- Safe by default: `git status/diff/log`. Push only when asked.
- Destructive ops (`reset --hard`, `clean`, `restore`, `rm`, force-push) require explicit ask.
- No amend unless asked.
- Big review: `git --no-pager diff --color=never`.

## Local install (dev)
- Symlink loop in README links every `skills/<name>/` into `~/.{claude,agents,cursor,gemini}/skills/`. Edits to the working tree go live immediately for every agent.

## Critical thinking
- Fix root cause, not band-aid.
- Unsure: read more code; if still stuck, ask with short options.
- Conflicts: call out; pick safer path.
