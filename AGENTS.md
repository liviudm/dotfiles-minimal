# AGENTS.md — dotfiles-minimal

Standalone macOS dotfiles: one Brewfile, one Bash 3.2 install.sh, small shared
helpers and a shared configuration mirror. No feature flags, env schema,
profiles, journals, reconciliation, framework, or agent instruction scaffolding.

- Inspect Git state and preserve unrelated work. Do not commit/push unless asked.
- The reference dotfiles repository is read-only; never change it for this setup.
- Preserve the approved package scope; Docker Desktop is the only container runtime.
- Install missing dependencies without automatic upgrades/removal or service startup.
- Use portable paths and support Apple Silicon and Intel Homebrew. Installation
  must not depend on the original checkout, username, volume, or reference repo.
- Quote expansions, use null-delimited file walks and macOS Bash 3.2 shell syntax.
- Back up regular files/directories with backup_if_not_symlink and numbered collisions.
- Preserve unexpected symlinks, including ancestors; stop with a clear diagnostic.
- Use ✓ for convergence, + for changes and ↻ for backups; reruns emit only ✓.
- Keep personal settings/identity/signing in ignored local overrides. Never track
  credentials, sessions, private host state, application containers or downloaded runtimes.
- Keep Neovim's complete configuration and lockfile; document fidelity exceptions.
- Update README and focused regression tests for contract/workflow changes.
- Tests use temporary homes and mocks. Never run a live installer audit unless
  explicitly requested after reviewing its effects; do not launch apps/services.
- Run bash tests/check.sh and review the final diff. Individual tests remain
  non-executable; executable mode is for entrypoints and managed launchers.

AGENTS.md is canonical. CLAUDE.md may only be a compatibility symlink.
