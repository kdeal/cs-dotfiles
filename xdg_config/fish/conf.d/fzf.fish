# colors taken from https://draculatheme.com/fzf
set -Ux FZF_COLORS "
    --color=fg:#f8f8f2,bg:#282a36,hl:#bd93f9 --color=fg+:#f8f8f2,bg+:#44475a,hl+:#bd93f9
    --color=info:#ffb86c,prompt:#50fa7b,pointer:#ff79c6
    --color=marker:#ff79c6,spinner:#ffb86c,header:#6272a4
"

set -Ux FZF_DEFAULT_COMMAND 'fd --type f --hidden --follow --exclude .git'
set -Ux FZF_CTRL_T_COMMAND $FZF_DEFAULT_COMMAND
set -Ux FZF_DEFAULT_OPTS $FZF_COLORS' --reverse --height=40%  --bind "ctrl-f:preview-page-down" --bind "ctrl-b:preview-page-up"'
set -Ux FZF_ALT_C_COMMAND 'fd --type d --hidden --follow --exclude .git'
