# Minimal macOS dotfiles

A standalone shell-and-symlink setup for Ghostty, Starship, tmux, Neovim,
and Zsh. Copy or clone this directory to any location on another Mac; it does
not need the original repository, username, volume, or host role. One `Brewfile`, one `install.sh`; no profiles, feature flags, or
uninstall reconciliation. Keep this checkout in place: installed links point here.

## Prerequisites and bootstrap

Use a macOS release supported by Homebrew and Docker Desktop, with internet
access and enough disk space for packages and editor downloads. Apple Silicon
uses `/opt/homebrew`; Intel uses `/usr/local`. Both paths are supported here;
upstream Homebrew currently classifies Intel as Tier 3. Compatibility means
Apple Silicon or Intel Macs on macOS versions supported by the selected
packages, not every historical macOS release. Docker Desktop supports the
current and two previous major releases; consult the upstream links below.

Install Apple's tools manually, finish their dialog, then install Homebrew:

```sh
xcode-select --install
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Follow Homebrew's printed shellenv instructions, then:

```sh
git clone https://github.com/liviudm/dotfiles-minimal.git "$HOME/dotfiles-minimal"
cd "$HOME/dotfiles-minimal"
./install.sh
```

Run as your own user, without `sudo`. The installer requires CLT and Homebrew
and fails with instructions before package or home changes when either is missing.
It installs missing packages with `brew bundle install --no-upgrade`, disables
automatic update/cleanup, and never runs bundle cleanup or removes packages.
Homebrew may still update a dependency when a new package requires it.
It does not start tmux, Docker, GUI applications, or services.

## Package inventory

| Purpose | Packages |
| --- | --- |
| Terminal | Ghostty, JetBrains Mono Nerd Font, Starship, tmux |
| Navigation | fzf, zoxide, sesh |
| Editor | neovim, tree-sitter-cli, ripgrep, fd, lazygit, trash, bat |
| Editor tooling | node, stylua, prettierd, ruff, shellcheck, shfmt |
| Development | git, gh, python, uv, jq, yq, glow |
| Cloud and Kubernetes | awscli, kubernetes-cli (`kubectl`), helm |
| Containers | Docker Desktop (`docker-desktop` cask) |

Homebrew resolves transitive libraries and runtimes. Docker Desktop supplies
Docker CLI and Compose after onboarding; there is no separate runtime or CLI
formula. CLT supplies clang/make for Tree-sitter and LuaSnip's jsregexp build.
Node/npm support Mason's JavaScript servers; Python supports editor tooling and
the separate tmux environment. macOS supplies Bash, Zsh, SSH, less, clipboard
commands, curl, tar/unzip, and terminfo tools. Git downloads plugins. fzf powers
the launcher, sesh, extrakto, link picker, and editor picker; bat/ripgrep/fd
support previews/search; trash supports Neo-tree deletion; lazygit supports the
floating Git UI. The link picker uses Python's standard library; extrakto uses
Python and macOS pbcopy. The command palette falls back to cat when optional
mdcat is absent, so mdcat is not installed. No additional language runtimes are required merely to parse
Go, C, or other configured syntax.

## Configuration and local overrides

`shared/<topic>/` mirrors paths below `$HOME`. The installer links files and the
whole Neovim directory. `lib/common.sh` holds backup, linking, and bootstrap
helpers. Downloaded plugins and runtime contents live under the user's home,
never in this checkout.

| Local file | Use |
| --- | --- |
| `~/.zshrc.local` | Interactive machine settings, aliases, private environment |
| `~/.zprofile.local` | Login environment |
| `~/.gitconfig.local` | Identity, signing, conditional includes and personal paths |
| `~/.tmux.conf.local` | Local tmux settings; loaded before TPM |
| `~/.config/nvim/init.local.lua` | Neovim customization; ignored in this checkout |
| `~/Library/Application Support/com.mitchellh.ghostty/config.local` | Ghostty overrides |
| `~/.config/sesh/sesh.toml` | Your own session shortcuts; no source personal paths copied |

Git keeps portable preferences and `osxkeychain` credential integration.
Create `~/.gitconfig.local` yourself, for example:

```gitconfig
[user]
    name = Your Name
    email = you@example.com
```

For SSH signing, add your own `[gpg] format = ssh`, `[user] signingkey`,
`[commit] gpgsign = true`, and `[gpg "ssh"] allowedSignersFile` entries locally.
Generate/provision keys on that machine. No identity or signing state is copied.
Zsh adds portable `~/.docker/bin` and `~/.local/bin` paths, initializes Starship
and zoxide, and uses Oh My Zsh as the shell baseline. Enabled bundled plugins are `git`,
`gh`, `docker`, `kubectl`, `helm`, `aws`, `node`, `ssh`, and `macos`, alongside
the four custom interactive plugins. It retains
Kubernetes pickers and SSH tmux pane titles. The AWS plugin's separate right
prompt is disabled so Starship controls the prompt. OMZ auto-updates are disabled.

## Kubernetes shortcuts

Oh My Zsh already provides resource shortcuts (`kgp`, `kgs`, `kgd`), apply,
logs, rollout, port-forward, and context aliases. These additions fill gaps:

| Alias | Command | Example |
| --- | --- | --- |
| `kg` | `kubectl get` | `kg pods -n staging` |
| `kd` | `kubectl describe` | `kd pod my-pod` |
| `kgy` | `kubectl get -o yaml` | `kgy deployment api` |
| `kgjson` | `kubectl get -o json` | `kgjson pod my-pod` |
| `kgwide` | `kubectl get -o wide` | `kgwide nodes` |
| `kdiff` | `kubectl diff` | `kdiff -f manifests/` |
| `kexplain` | `kubectl explain` | `kexplain deployment.spec` |
| `kapi` | `kubectl api-resources` | `kapi --namespaced=true` |
| `kcan` | `kubectl auth can-i` | `kcan get secrets -n staging` |
| `ktp` | `kubectl top pods` | `ktp -A --sort-by=memory` |
| `ktn` | `kubectl top nodes` | `ktn --sort-by=cpu` |
| `klprev` | `kubectl logs --previous` | `klprev my-pod -c api` |

`ktp`/`ktn` require cluster metrics support. `kdiff` returns 1 when differences
exist. `klprev` retrieves the previous container instance's logs. `kctx`, `kns`,
and `klog` retain their fzf pickers. All shortcuts accept normal kubectl flags.

## Plugin and editor bootstrap

The installer clones Oh My Zsh and fzf-tab, you-should-use, autosuggestions,
and syntax-highlighting, plus TPM and **every plugin declared in the managed
tmux config**. Cloning directly avoids starting a tmux server during installation.
Existing checkouts must have the expected origin and are never reset or pulled.
Local extra TPM plugins are your responsibility (`Ctrl-a`, then `I` in tmux).

`tmux-window-name` needs both `python` and `python3`. The installer creates
`~/.local/share/dotfiles-minimal/tmux-python` with `python3 -m venv`, installs
libtmux there, and sets tmux's plugin/hook PATH to its bin directory before TPM.
No system pip override is used. If a Homebrew Python upgrade breaks the venv,
move that directory aside and rerun the installer. Restart an existing tmux
server or reload `~/.tmux.conf` after installing this setup.

Ghostty uses Dracula, JetBrainsMono Nerd Font 13, and the source window,
clipboard and keybindings. Each surface opens the tmux session picker; cancel
for a login shell. Nested tmux falls back to a shell. Local xterm-ghostty
terminfo is compiled from the application's bundled database only when absent.
The installer finds Ghostty in `~/Applications`, `/Applications`, or Homebrew's
cask staging tree. For another location, run
`GHOSTTY_APP="/your/app directory/Ghostty.app" ./install.sh`.
tmux preserves Dracula, Ctrl-a, pane navigation/resizing, true color/clipboard,
resurrect/continuum, SSH titles, sesh, extrakto, links and command palette.
No saved sessions or host overrides are imported.

Start `nvim` with internet access and let Lazy finish plugin downloads/builds.
The complete source config and `lazy-lock.json` are preserved. Use `:Lazy restore`
to enforce the copied lock after bootstrap; `:Lazy` shows failed builds for retry.
Mason installs pyright, ruff, bash-language-server, lua-language-server, json-lsp,
yaml-language-server, marksman and taplo. Taplo also supplies TOML formatting.
Tree-sitter downloads/builds bash, c, diff, git_config, gitcommit, gitignore, go,
json, jsonc, lua, luadoc, markdown, markdown_inline, python, query, regex, toml,
vim, vimdoc and yaml parsers. Open a real file to trigger deferred LSP setup,
then inspect `:Mason`, `:checkhealth`, `:ConformInfo` and `:Lazy`; allow downloads
and retry failed installs/builds there. The config uses Neovim's modern LSP API
(0.11+). Completion may download Blink's prebuilt fuzzy matcher.
Dracula (matching Ghostty and tmux), keybindings, completion, lint/format, Git, navigation and
plugin choices remain unchanged. Starship's Kubernetes context appears under
`~/git` and its subdirectories.

To apply the Dracula theme change to an existing installation, run `:Lazy restore`
and restart Neovim.

## Editor navigation

`vi` and `vim` are shell aliases for `nvim`. Use `Ctrl-h/j/k/l` to move
left/down/up/right between Neovim splits, the explorer, embedded terminals,
and adjacent tmux panes. Ghostty explicitly unbinds these keys so it passes
them to the terminal application; its Cmd-D/Cmd-Shift-D split shortcuts are
also disabled. Use tmux for terminal splits. Reload Ghostty with Cmd-Shift-,
after applying this configuration. Remove conflicting Ctrl-h/j/k/l bindings
from any Ghostty `config.local` file (included files are processed last).
In insert mode press Escape first; navigation out of
an embedded terminal leaves terminal input mode. These keys use the existing
vim-tmux-navigator plugin on both sides; restart Neovim/reload tmux after changes.
`Ctrl-a` then `h/j/k/l` remains tmux's own pane selection. In the explorer,
plain `h` closes a node and `l` opens it; `Space e` toggles the explorer.
Neovim buffers still use Tab/Shift-Tab, and `Space ws`/`Space wv` create splits.

## Updates and recovery

Rerun `./install.sh` to fill missing pieces; converged runs emit only `  ✓ `.
Upgrade deliberately with `brew update` and `brew bundle upgrade --file=Brewfile`.
Use `omz update` for Oh My Zsh, `git -C <plugin-dir> pull --ff-only` for Zsh
plugins, TPM prefix + U for tmux, and `:Lazy update`, `:MasonUpdate`, `:TSUpdate`
for the editor. Review changes to `lazy-lock.json` after editor updates.

Every existing regular configuration file or directory being replaced is backed
up before the managed symlink is created. The installer moves it to
`<path>.dotfiles-minimal.bak`, then `.bak.1`, `.bak.2`, etc. Existing backups,
including dangling links, are preserved. If the backup move fails, linking
stops and the original is left in place. Converged reruns create no new backups. Unexpected target/ancestor symlinks
and unexpected plugin/runtime contents stop installation with a diagnostic.
Review and move them yourself; the installer never overwrites those links.
To recover, remove only the managed link and move the chosen backup back.
A failed install may leave completed steps; correct the error and rerun.
There is no automatic uninstall, package removal, or saved-state transfer.

## Authentication and first launch

Open Docker Desktop yourself, accept onboarding/terms, choose CLI installation
options and answer its permission prompts. Its engine stays stopped until you
launch it. Existing `~/.docker` configuration and credentials are not rewritten.
Authenticate with `docker login`, `gh auth login`, and your organization's
`aws configure sso` / `aws sso login` workflow as needed. Obtain kubeconfig and
cluster credentials through your provider; use `kctx` and `kns` afterward.
Never copy credentials, sessions, Keychain state, or application containers.

## Development and verification

Run `bash tests/check.sh` (requires shellcheck, shfmt, ripgrep and Zsh). Tests
use temporary homes and mocked package/plugin/runtime commands, never the live
installer. They cover backups/collisions, spaces, symlinks, prerequisites,
failures, plugin/runtime wiring and converged reruns, plus launcher branches.
The check includes Bash 3.2 syntax, ShellCheck, shell formatting, Zsh syntax,
behavior, whitespace and Git diff checks when Git metadata exists.
Source parity is documented in `docs/parity.md`. No live installation was run
while creating this setup; real package downloads, GUI onboarding and editor
network bootstrap remain first-run validation steps.

Upstream details checked on 2026-10-09:
[Homebrew bootstrap](https://docs.brew.sh/Installation),
[Bundle no-upgrade behavior](https://docs.brew.sh/Manpage),
[Ghostty terminfo](https://ghostty.org/docs/help/terminfo),
[Ghostty local config includes](https://ghostty.org/docs/config/reference#config-file),
[tmux-window-name Python dependency](https://github.com/ofirgall/tmux-window-name),
[Docker Desktop setup](https://docs.docker.com/desktop/setup/install/mac-install/),
[extrakto requirements](https://github.com/laktak/extrakto#requirements),
[link picker requirements](https://github.com/alberti42/tmux-fzf-links),
[command palette requirements](https://github.com/lost-melody/tmux-command-palette).
