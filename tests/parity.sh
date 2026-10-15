#!/usr/bin/env bash
# Optional read-only reference check; no runtime dependency on the source repo.
set -euo pipefail
cd "$(dirname "$0")/.."
: "${SOURCE_DOTFILES:?Set SOURCE_DOTFILES to the read-only reference checkout}"
python3 - <<'PY'
import os
import json
from pathlib import Path
source = Path(os.environ['SOURCE_DOTFILES'])
# Only the documented terminal/explorer navigation additions may differ.
nvim_root = Path('shared/nvim')
source_files = {p.relative_to(source / nvim_root) for p in (source / nvim_root).rglob('*') if p.is_file()}
actual_files = {p.relative_to(nvim_root) for p in nvim_root.rglob('*') if p.is_file() and not p.name.endswith('.local.lua')}
assert actual_files == source_files
for path in source_files:
    actual = (nvim_root / path).read_text()
    if path.name == 'tmux-navigator.lua':
        actual = '\n'.join(line for line in actual.split('\n') if 'mode = "t"' not in line)
    elif path.name == 'neo-tree.lua':
        actual = '\n'.join(line for line in actual.split('\n') if 'Buffer-local tree bindings' not in line and '["<C-' not in line)
    expected = (source / nvim_root / path).read_text()
    if path.name == 'colorscheme.lua':
        expected = expected.replace('folke/tokyonight.nvim', 'Mofiqul/dracula.nvim').replace('opts = { style = "moon" }', 'opts = {}').replace('require("tokyonight")', 'require("dracula")').replace('tokyonight-moon', 'dracula')
    elif path.name == 'lazy.lua':
        expected = expected.replace('tokyonight-moon', 'dracula')
    elif path.name == 'statusline.lua':
        expected = expected.replace('theme = "auto"', 'theme = "dracula-nvim"')
    elif path.name == 'lazy-lock.json':
        expected_lock, actual_lock = json.loads(expected), json.loads(actual)
        del expected_lock['tokyonight.nvim']
        assert actual_lock.pop('dracula.nvim') == {'branch': 'main', 'commit': 'ae752c13e95fb7c5f58da4b5123cb804ea7568ee'}
        assert actual_lock == expected_lock
        continue
    assert actual == expected, str(path)

relative = Path('shared/starship/.config/starship.toml')
expected = (source / relative).read_text().replace('~/projects/clients/**', '~/git/**').replace('only under ~/projects/clients', 'only under ~/git').replace('[[ "$PWD" == "$HOME/projects/clients"* ]]', '[[ "$PWD" == "$HOME/git" || "$PWD" == "$HOME/git/"* ]]')
assert relative.read_text() == expected

relative = Path('shared/ghostty/Library/Application Support/com.mitchellh.ghostty/config.ghostty')
expected = (source / relative).read_text().replace('cmd+d=new_split:right', 'cmd+d=unbind').replace('cmd+shift+d=new_split:down', 'cmd+shift+d=unbind')
expected += '\n# Optional machine-local settings (not tracked).\nconfig-file = ?config.local\n'
expected += '\n# Pass directional keys to tmux/Neovim instead of Ghostty splits.\n'
expected += ''.join(f'keybind = ctrl+{key}=unbind\n' for key in 'hjkl')
assert relative.read_text() == expected
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
