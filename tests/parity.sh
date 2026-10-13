#!/usr/bin/env bash
# Optional read-only reference check; no runtime dependency on the source repo.
set -euo pipefail
cd "$(dirname "$0")/.."
: "${SOURCE_DOTFILES:?Set SOURCE_DOTFILES to the read-only reference checkout}"
diff -r "$SOURCE_DOTFILES/shared/nvim" shared/nvim
python3 - <<'PY'
import os
from pathlib import Path
source = Path(os.environ['SOURCE_DOTFILES'])
relative = Path('shared/starship/.config/starship.toml')
expected = (source / relative).read_text().replace('~/projects/clients/**', '~/git/**').replace('only under ~/projects/clients', 'only under ~/git').replace('[[ "$PWD" == "$HOME/projects/clients"* ]]', '[[ "$PWD" == "$HOME/git" || "$PWD" == "$HOME/git/"* ]]')
assert relative.read_text() == expected

relative = Path('shared/ghostty/Library/Application Support/com.mitchellh.ghostty/config.ghostty')
assert relative.read_text() == (source / relative).read_text() + '\n# Optional machine-local settings (not tracked).\nconfig-file = ?config.local\n'
relative = Path('shared/ghostty/.local/bin/ghostty-tmux')
addition = '''# Keep both plugin interpreter names available after refreshing an existing server.
venv_bin="$HOME/.local/share/dotfiles-minimal/tmux-python/bin"
if [ -d "$venv_bin" ]; then
  PATH="$venv_bin:$PATH"
  export PATH
fi

'''
assert relative.read_text().replace(addition, '') == (source / relative).read_text()
relative = Path('shared/tmux/.tmux.conf')
actual = relative.read_text().replace('# Optional machine-local overrides (before TPM)', '# Per-host overrides (may declare extra @plugin lines; MUST be before tpm run)')
addition = '''# Both plugin probes (python) and executable hooks (python3) use the venv.
run-shell 'tmux set-environment -g PATH "$HOME/.local/share/dotfiles-minimal/tmux-python/bin:$PATH"'
run-shell 'PATH="$HOME/.local/share/dotfiles-minimal/tmux-python/bin:$PATH" "$HOME/.tmux/plugins/tpm/tpm"' '''.rstrip()
assert actual.replace(addition, "run '~/.tmux/plugins/tpm/tpm'") == (source / relative).read_text()
relative = Path('shared/git/.gitconfig')
assert relative.read_text() == (source / relative).read_text().split('[gpg]')[0]
print('Reference parity checks passed')
PY
