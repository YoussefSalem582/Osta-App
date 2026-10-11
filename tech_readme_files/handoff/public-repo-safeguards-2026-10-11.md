# Handoff — public-repo safeguards (2026-10-11)

## 1. Goal

The repo is public (view-only licence). Make every AI agent file and skill know that, so nothing private gets committed, and land it on `main`.

## 2. Current status

2026-10-11 — done on `chore/public-repo-safeguards` → PR to `develop` → release PR `develop → main`.

## 3. Active files

- `AGENTS.md` — new § Public Repository (canonical rule).
- `tool/check_public.sh`, `tool/hooks/pre-commit` — guard script and hook.
- `.github/workflows/ci.yml` — `public-check` job.
- `.claude/skills/osta-public-repo-check/`, `.agents/skills/public-repo-check/` — agent skill.

## 4. Changes made

- Public-repo section + pointers in all agent shims and both security rules.
- Guard script (pre-commit + CI), `.gitignore` secret entries.
- Absolute local path removed from `.claude/settings.json` and shims; local notes now in git-ignored `CLAUDE.local.md`.
- Commit author for this clone set to the owner's name/email (`git config user.*`).

## 5. Failed attempts

None.

## 6. Next steps

1. Each teammate runs `git config core.hooksPath tool/hooks` once in their clone.
2. Consider enabling GitHub secret scanning + push protection in the repo settings (owner action).
