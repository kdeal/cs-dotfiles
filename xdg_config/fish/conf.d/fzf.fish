# colors taken from https://github.com/ianchesal/nord-fzf
set -Ux FZF_COLORS "
    --color=fg:#e5e9f0,bg:#2e333f,hl:#81a1c1
    --color=fg+:#e5e9f0,bg+:#2e333f,hl+:#81a1c1
    --color=info:#eacb8a,prompt:#bf6069,pointer:#b48dac
    --color=marker:#a3be8b,spinner:#b48dac,header:#a3be8b
"

set -Ux FZF_DEFAULT_COMMAND 'fd --type f --hidden --follow --exclude .git'
set -Ux FZF_CTRL_T_COMMAND $FZF_DEFAULT_COMMAND
set -Ux FZF_DEFAULT_OPTS $FZF_COLORS' --reverse --height=40%  --bind "ctrl-f:preview-page-down" --bind "ctrl-b:preview-page-up"'
set -Ux FZF_ALT_C_COMMAND 'fd --type d --hidden --follow --exclude .git'
