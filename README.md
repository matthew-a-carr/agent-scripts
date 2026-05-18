# Agent Scripts

A plugin marketplace of [Agent Skills](https://agentskills.io)-format skills for Claude Code, Codex CLI, Cursor, Gemini CLI, and any other host that speaks the open spec.

`AGENTS.md` (with its `CLAUDE.md` symlink) holds repo-local conventions for editing the skills here — not org-wide agent instructions. Plugin scope is `skills/` only.

Attribution for forked skills: see [`skills/ATTRIBUTION.md`](skills/ATTRIBUTION.md).

## Install

### Claude Code

```text
/plugin marketplace add matthew-a-carr/agent-scripts
/plugin install matthew-a-carr@matthew-a-carr-skills
```

### Codex CLI

```text
$skill-installer matthew-a-carr/agent-scripts
```

### Any agent (skills.sh)

```bash
npx skills@latest add matthew-a-carr/agent-scripts
```

### Symlink loop (live updates via `git pull`)

```bash
for skill in skills/*/; do
  name=$(basename "$skill")
  for dir in ~/.claude/skills ~/.agents/skills ~/.cursor/skills ~/.gemini/skills; do
    mkdir -p "$dir"
    ln -sf "$(pwd)/$skill" "$dir/$name"
  done
done
```
