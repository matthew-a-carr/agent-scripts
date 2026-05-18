---
name: dependabot-pr-merge
description: Review and merge Dependabot PRs only when CI is green and release notes show no breaking changes.
---

# Dependabot PR Merge

Use when asked to triage and merge Dependabot PRs in the current repo.

## Guardrails
- CI must be green (all required checks).
- No breaking changes in release notes.
- Codebase compatibility looks OK (no removed APIs, config changes, or new peers).
- If any guardrail fails, do not merge. Report why.

## Steps

1) List open Dependabot PRs:

```
gh pr list --search "author:app/dependabot is:pr is:open" --json number,title,headRefName
```

2) For each PR, verify merge gates:

```
gh pr view <number> --json number,title,headRefName,isDraft,mergeable,reviewDecision,statusCheckRollup
```

Only continue if:
- `isDraft` is false
- `mergeable` is `MERGEABLE`
- all `statusCheckRollup` entries are `SUCCESS`
- `reviewDecision` is `APPROVED` if reviews are required

3) Inspect the diff:

```
gh pr diff <number>
```

Identify each bumped dependency and version.

4) Check release notes and compatibility:
- Prefer GitHub releases if available:
  - `gh release view vX.Y.Z -R owner/repo`
  - fallback: `gh release view X.Y.Z -R owner/repo`
- Otherwise read the changelog or release notes with WebFetch.
- Look for breaking changes, peer dependency updates, or required config changes.
- Scan the codebase for affected APIs if the notes mention deprecations.

5) Merge if all green and compatible:

```
gh repo view --json viewerDefaultMergeMethod
```

Use the repo default merge method. Example for squash:

```
gh pr merge <number> --squash --delete-branch
```

6) Report results:
- Merged PRs (numbers + titles).
- Skipped PRs + reason (CI red, breaking notes, review needed, not mergeable).
