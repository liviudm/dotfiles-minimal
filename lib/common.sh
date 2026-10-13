#!/usr/bin/env bash
# Sourced by install.sh. Bash 3.2 compatible.
log() { printf '  %s %s\n' "$1" "$2"; }
fail() {
  printf 'dotfiles-minimal: %s\n' "$*" >&2
  return 1
}

# Refuse symlinked parents: never write through an unexpected mirror ancestor.
safe_parent() {
  local parent
  parent=$(dirname "$1")
  while [ "$parent" != "$HOME" ] && [ "$parent" != / ]; do
    [ ! -L "$parent" ] || {
      fail "preserving symlinked parent: $parent"
      return 1
    }
    parent=$(dirname "$parent")
  done
}
backup_if_not_symlink() {
  local path="$1" backup="$1.dotfiles-minimal.bak" n=0
  [ ! -L "$path" ] || {
    fail "preserving unexpected symlink: $path"
    return 1
  }
  if [ -e "$path" ]; then
    while [ -e "$backup" ] || [ -L "$backup" ]; do
      n=$((n + 1))
      backup="$path.dotfiles-minimal.bak.$n"
    done
    mv "$path" "$backup" || return 1
    log '↻' "$path -> $backup"
  fi
}
link_file() {
  local source="$1" target="$2"
  safe_parent "$target" || return 1
  if [ -L "$target" ] && [ "$(readlink "$target")" = "$source" ]; then
    log '✓' "$target"
    return
  fi
  backup_if_not_symlink "$target" || return 1
  mkdir -p "$(dirname "$target")" || return 1
  ln -s "$source" "$target" || return 1
  log '+' "$target"
}
clone_repo() {
  local repo="$1" target="$2"
  safe_parent "$target" || return 1
  [ ! -L "$target" ] || {
    fail "preserving plugin symlink: $target"
    return 1
  }
  if [ -e "$target" ]; then
    [ -d "$target/.git" ] || {
      fail "unexpected plugin contents: $target"
      return 1
    }
    [ "$(git -C "$target" remote get-url origin)" = "https://github.com/$repo.git" ] || {
      fail "unexpected plugin origin: $target"
      return 1
    }
    log '✓' "$repo"
    return
  fi
  mkdir -p "$(dirname "$target")" || return 1
  local staging
  staging=$(mktemp -d "${target}.download.XXXXXX") || return 1
  if ! git clone --quiet --depth 1 "https://github.com/$repo.git" "$staging"; then
    rm -rf "$staging"
    fail "clone failed: $repo"
    return 1
  fi
  mv "$staging" "$target" || return 1
  log '+' "$repo"
}
install_plugins() {
  clone_repo ohmyzsh/ohmyzsh "$HOME/.oh-my-zsh" || return 1
  local repo name
  for repo in Aloxaf/fzf-tab MichaelAquilina/zsh-you-should-use zsh-users/zsh-autosuggestions zsh-users/zsh-syntax-highlighting; do
    name=${repo##*/}
    [ "$name" != zsh-you-should-use ] || name=you-should-use
    clone_repo "$repo" "$HOME/.oh-my-zsh/custom/plugins/$name" || return 1
  done
  # Derive all TPM repositories from the managed config, without starting tmux.
  while IFS= read -r repo; do
    name=${repo##*/}
    clone_repo "$repo" "$HOME/.tmux/plugins/$name" || return 1
  done < <(sed -n "s/^set -g @plugin '\([^']*\)'$/\1/p" "$ROOT/shared/tmux/.tmux.conf")
}
install_python() {
  local venv="$HOME/.local/share/dotfiles-minimal/tmux-python"
  safe_parent "$venv" || return 1
  [ ! -L "$venv" ] || {
    fail "preserving runtime symlink: $venv"
    return 1
  }
  if [ -e "$venv" ] && [ ! -f "$venv/pyvenv.cfg" ]; then
    fail "unexpected runtime contents: $venv"
    return 1
  fi
  if [ ! -x "$venv/bin/python" ]; then
    python3 -m venv "$venv" || return 1
    log '+' 'tmux Python environment'
  fi
  if "$venv/bin/python" -c 'import libtmux' >/dev/null 2>&1; then
    log '✓' 'tmux libtmux'
  else
    "$venv/bin/python" -m pip install --disable-pip-version-check 'libtmux>0.16' || return 1
    "$venv/bin/python" -c 'import libtmux' || return 1
    log '+' 'tmux libtmux'
  fi
}
ghostty_terminfo_db() {
  local app caskroom
  if [ -n "${GHOSTTY_APP:-}" ]; then
    [ -d "$GHOSTTY_APP/Contents/Resources/terminfo" ] || {
      fail "GHOSTTY_APP has no bundled terminfo: $GHOSTTY_APP"
      return 1
    }
    printf '%s\n' "$GHOSTTY_APP/Contents/Resources/terminfo"
    return
  fi
  for app in "$HOME/Applications/Ghostty.app" /Applications/Ghostty.app; do
    if [ -d "$app/Contents/Resources/terminfo" ]; then
      printf '%s\n' "$app/Contents/Resources/terminfo"
      return
    fi
  done
  caskroom=$(brew --caskroom ghostty) || return 1
  if [ -d "$caskroom" ]; then
    while IFS= read -r -d '' app; do
      if [ -d "$app/Contents/Resources/terminfo" ]; then
        printf '%s\n' "$app/Contents/Resources/terminfo"
        return
      fi
    done < <(find "$caskroom" -name Ghostty.app -prune -print0)
  fi
  fail 'Ghostty terminfo not found; set GHOSTTY_APP to the installed Ghostty.app path'
}
install_terminfo() {
  local db
  if infocmp -x xterm-ghostty >/dev/null 2>&1; then
    log '✓' 'xterm-ghostty terminfo'
    return
  fi
  safe_parent "$HOME/.terminfo/x" || return 1
  db=$(ghostty_terminfo_db) || return 1
  local staging entry relative target
  staging=$(mktemp -d) || return 1
  if ! infocmp -A "$db" -x xterm-ghostty | tic -x -o "$staging" -; then
    rm -rf "$staging"
    return 1
  fi
  while IFS= read -r -d '' entry; do
    relative=${entry#"$staging/"}
    target="$HOME/.terminfo/$relative"
    safe_parent "$target" || {
      rm -rf "$staging"
      return 1
    }
    backup_if_not_symlink "$target" || {
      rm -rf "$staging"
      return 1
    }
    mkdir -p "$(dirname "$target")" || {
      rm -rf "$staging"
      return 1
    }
    mv "$entry" "$target" || {
      rm -rf "$staging"
      return 1
    }
  done < <(find "$staging" -type f -print0)
  rm -rf "$staging"
  infocmp -x xterm-ghostty >/dev/null || {
    fail "installed terminfo could not be read"
    return 1
  }
  log '+' 'xterm-ghostty terminfo'
}
