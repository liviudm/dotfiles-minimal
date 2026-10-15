# Configuration fidelity

Verified against the read-only `/Volumes/M4/projects/personal/dotfiles` working
tree on 2026-10-09, including hidden files. Its existing Git and Zprofile edits
were inspected and left intact. No private trees, host overlays, credentials,
sessions, `.env` state, or application containers were copied.

- **Neovim:** all 25 files, including lazy-lock.json and after/ftplugin files,
  preserve the source except for terminal-mode and explicit explorer
  Ctrl-h/j/k/l navigation and Dracula replacing Tokyo Night Moon (including
  the Lazy fallback, pinned theme plugin, and matching Lualine theme). Other
  plugin choices, LSP/tool/parser lists, keybindings, completion, Git, lint
  and formatting remain intact.
- **Starship:** matches the source except that Kubernetes context display is
  scoped to `~/git` and its subdirectories instead of `~/projects/clients*`.
- **Ghostty:** original appearance and behavior settings match. Native split
  creation shortcuts are disabled and Ctrl-h/j/k/l are explicitly unbound so
  navigation reaches tmux/Neovim. One optional `?config.local`
  include was appended. The launcher matches except for prepending the isolated
  tmux Python bin path, so refreshing an existing server preserves libtmux wiring.
- **tmux:** all settings/plugin declarations match. The local-override comment
  is generalized and TPM launch gains venv PATH wiring for both Python names.
  No host overrides or resurrect data are imported. TPM and all ten declared
  repositories (including TPM itself) are cloned without starting a server.
- **Zsh:** the source plugin list plus bundled `gh`, `helm`, and `aws` plugins,
  history/editor/cursor settings, prompt/zoxide,
  SSH pane-title function, and Kubernetes helper functions were extracted from
  the source. Template comments, omp/Conda/LM Studio/AI additions were removed.
  `vi` and `vim` launch Neovim.
  Additional kubectl shortcuts cover generic get/describe, output formats,
  diffs, API discovery, authorization checks, metrics, and previous logs.
  Login Homebrew detection supports both prefixes; Docker's absolute user path
  became `$HOME/.docker/bin`. Optional local files are never copied from source.
- **Git:** portable settings through the local include match the source exactly.
  Its trailing personal signing settings are omitted; README documents local setup.
- **sesh:** the binary and tmux picker are retained. The source's personal
  dotfiles session path is omitted; user session definitions remain local.

Run the optional reference comparison while both checkouts exist:

```sh
SOURCE_DOTFILES=/path/to/reference-dotfiles bash tests/parity.sh
```

Normal installation and default tests are fully standalone. The default suite
also compiles all Neovim Lua files with `nvim -u NONE` when available, without
loading plugins or downloading anything. Package downloads, real plugin builds,
editor/Mason/Tree-sitter downloads, authentication and Docker onboarding are
manual first-run checks; none ran against the live home during creation.

Portability follow-up (2026-10-13): bootstrap instructions use an arbitrary
checkout path. Ghostty discovery supports user Applications and custom app
locations. Installer tests run a standalone relocated copy with spaces in
both checkout and home paths; terminfo tests need no live Ghostty application.
