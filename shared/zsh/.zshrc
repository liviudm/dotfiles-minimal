# Portable interactive shell; personal additions belong in ~/.zshrc.local.
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=""
zstyle ':omz:update' mode disabled
plugins=(git node docker kubectl ssh macos fzf-tab you-should-use zsh-autosuggestions zsh-syntax-highlighting)
source "$ZSH/oh-my-zsh.sh"
HISTSIZE=50000
SAVEHIST=50000
setopt EXTENDED_HISTORY INC_APPEND_HISTORY HIST_IGNORE_DUPS HIST_IGNORE_SPACE HIST_REDUCE_BLANKS
export EDITOR=nvim VISUAL=nvim
export PATH="$HOME/.local/bin:$HOME/.docker/bin:$PATH"
_cursor_beam() { printf '\e[5 q' }
precmd_functions+=(_cursor_beam)
eval "$(starship init zsh)"
eval "$(zoxide init zsh)"

# ssh wrapper: tag the tmux pane title as "ssh:<shorthost>" via OSC 2 so
# tmux's automatic-rename-format can pick it up as the window name when
# this is the active pane. Parses ssh flags that take an argument so the
# last non-flag arg is the actual destination.
ssh() {
  local arg host="" skip_next=0
  for arg in "$@"; do
    if (( skip_next )); then skip_next=0; continue; fi
    case "$arg" in
      -b|-c|-D|-E|-e|-F|-I|-i|-J|-L|-l|-m|-O|-o|-p|-Q|-R|-S|-W|-w) skip_next=1 ;;
      -*) ;;
      *)  host="$arg"; break ;;
    esac
  done
  local remote="${host##*@}"; remote="${remote%%.*}"
  if [[ -n "$remote" && -n "${TMUX:-}" ]]; then
    printf '\033]2;ssh:%s\033\\' "$remote"
    command ssh "$@"
    printf '\033]2;\033\\'
  else
    command ssh "$@"
  fi
}

# kubectl helpers. The `kubectl` oh-my-zsh plugin provides the bulk
# `k*` alias surface (k, kgp, kgs, kaf, kdel, ...); these add the
# fzf-driven flows omz doesn't ship.
kctx() {
  # Switch context. No arg → fzf picker.
  if [[ -n "$1" ]]; then
    kubectl config use-context "$1"
  else
    local ctx
    ctx=$(kubectl config get-contexts -o name | fzf --height=40% --reverse --prompt='context> ') || return
    kubectl config use-context "$ctx"
  fi
}

kns() {
  # Switch namespace on current context. No arg → fzf picker.
  local ns
  if [[ -n "$1" ]]; then
    ns="$1"
  else
    ns=$(kubectl get ns -o name | sed 's|namespace/||' | fzf --height=40% --reverse --prompt='namespace> ') || return
  fi
  kubectl config set-context --current --namespace="$ns"
}

klog() {
  # Tail logs from a pod picked via fzf. Extra args forwarded to `kubectl logs`.
  local pod
  pod=$(kubectl get pods -o name | sed 's|pod/||' | fzf --height=40% --reverse --prompt='pod> ') || return
  kubectl logs -f "$pod" "$@"
}

[[ ! -f "$HOME/.zshrc.local" ]] || source "$HOME/.zshrc.local"
