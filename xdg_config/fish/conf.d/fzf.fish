set -Ux FZF_DEFAULT_COMMAND 'fd --type f --hidden --follow --exclude .git'
set -Ux FZF_CTRL_T_COMMAND $FZF_DEFAULT_COMMAND
set -Ux FZF_DEFAULT_OPTS '--reverse --height=40%  --bind "ctrl-f:preview-page-down" --bind "ctrl-b:preview-page-up"'
set -Ux FZF_ALT_C_COMMAND 'fd --type d --hidden --follow --exclude .git'
