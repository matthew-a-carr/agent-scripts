#!/usr/bin/env bash
# Validate every skill in skills/ against the agentskills.io spec.
# Exits 1 if any check fails. Designed to run from repo root in CI.

set -euo pipefail

fail=0
fail_msg() { printf "  ✗ %s\n" "$*"; fail=1; }
ok_msg()   { printf "  ✓ %s\n" "$*"; }

# 1. Manifests parse
for manifest in .claude-plugin/plugin.json .claude-plugin/marketplace.json; do
  if jq empty "$manifest" >/dev/null 2>&1; then
    ok_msg "$manifest is valid JSON"
  else
    fail_msg "$manifest is not valid JSON"
  fi
done

# 2. Per-skill checks
for skill_dir in skills/*/; do
  name=$(basename "$skill_dir")
  printf "\n[skills/%s]\n" "$name"
  skill_md="${skill_dir}SKILL.md"

  if [ ! -f "$skill_md" ]; then
    fail_msg "no SKILL.md"
    continue
  fi

  # Frontmatter delimited by --- on lines 1 and N
  if ! head -1 "$skill_md" | grep -qE '^---\s*$'; then
    fail_msg "SKILL.md missing opening frontmatter delimiter (---)"
    continue
  fi
  fm_end=$(awk 'NR>1 && /^---[[:space:]]*$/ {print NR; exit}' "$skill_md")
  if [ -z "$fm_end" ]; then
    fail_msg "SKILL.md frontmatter is not closed"
    continue
  fi
  ok_msg "frontmatter delimited (lines 1..$fm_end)"

  # name field matches directory
  fm_name=$(awk -v end="$fm_end" 'NR>1 && NR<end && /^name:[[:space:]]/ {sub(/^name:[[:space:]]+/,""); print; exit}' "$skill_md")
  if [ "$fm_name" = "$name" ]; then
    ok_msg "name '$fm_name' matches dir"
  else
    fail_msg "name '$fm_name' does not match dir '$name'"
  fi

  # description field present
  if awk -v end="$fm_end" 'NR>1 && NR<end && /^description:/ {found=1} END{exit !found}' "$skill_md"; then
    ok_msg "description present"
  else
    fail_msg "description field missing"
  fi

  # Layout: only SKILL.md allowed at skill root (supporting docs in references/)
  extras=$(find "$skill_dir" -maxdepth 1 -name "*.md" ! -name SKILL.md 2>/dev/null | wc -l | tr -d ' ')
  if [ "$extras" = "0" ]; then
    ok_msg "no extra .md files at skill root"
  else
    fail_msg "extra .md files at root (should live in references/):"
    find "$skill_dir" -maxdepth 1 -name "*.md" ! -name SKILL.md -printf "      %p\n" 2>/dev/null \
      || find "$skill_dir" -maxdepth 1 -name "*.md" ! -name SKILL.md | sed 's/^/      /'
  fi

  # Internal markdown links resolve
  bad_links=0
  while IFS= read -r link; do
    case "$link" in
      ""|http*|/*|"#"*) continue ;;
    esac
    target="${skill_dir}${link%%#*}"
    if [ ! -e "$target" ]; then
      fail_msg "broken link in SKILL.md: $link"
      bad_links=$((bad_links + 1))
    fi
  done < <(grep -oE '\]\([^)]+\)' "$skill_md" | sed 's/^](//; s/)$//')
  [ "$bad_links" = "0" ] && ok_msg "all internal links resolve"
done

echo
if [ "$fail" = "0" ]; then
  echo "All skills validated."
  exit 0
else
  echo "Validation failed."
  exit 1
fi
