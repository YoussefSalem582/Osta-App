---
name: osta-public-repo-check
description: Use before every commit, push or PR in OSTA, and whenever writing docs, configs, tests or examples. The repository is PUBLIC (view-only licence) - checks that no secrets, real hosts/IPs, personal data, local paths or third-party/client material get committed.
---

# OSTA is a public repository

Everything committed is readable by anyone, forever (git history). The
licence (`LICENSE`, `OWNERSHIP.md`) keeps the rights with the team, but it
does not hide content. Treat every tracked file as published.

## Before every commit

1. Run `git diff --cached` and read it. Look for:
   - Secrets: API keys (Google Maps, Firebase), tokens, passwords,
     `key.properties`, keystores, `.env*`, signing files.
   - Personal data: customer/test-user emails, phone numbers, addresses,
     real names beyond `OWNERSHIP.md`, screenshots that show any of these.
   - Real infrastructure beyond the documented `BASE_URL`: server IPs,
     SSH hosts, admin URLs, database names.
   - Local machine details: absolute paths (`/Volumes/...`, `/Users/...`) - public-ok
     go in the git-ignored `CLAUDE.local.md`, never in tracked files.
   - Code or assets copied from other private or client projects.
2. Use placeholders in docs and tests (`test@example.com`, `+20 100 000 0000`,
   `fake-token`). A deliberate fake that looks real needs `public-ok` on the
   same line.
3. The pre-commit hook `tool/check_public.sh` (enabled by
   `git config core.hooksPath tool/hooks`) and the CI `public-check` job block
   the obvious patterns. They are a safety net, not a replacement for step 1.

## If something private was already pushed

Stop and tell the owner. Rotate the secret first (removing it from git does
not make it safe again); history rewriting on this shared repo is the owner's
call, never an agent's.
