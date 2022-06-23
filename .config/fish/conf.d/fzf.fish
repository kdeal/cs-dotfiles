# colors taken from https://github.com/nicodebo/base16-fzf/blob/master/fish/base16-gruvbox-dark-medium.fish
set -l color00 '#282828'
set -l color01 '#3c3836'
set -l color02 '#504945'
set -l color03 '#665c54'
set -l color04 '#bdae93'
set -l color05 '#d5c4a1'
set -l color06 '#ebdbb2'
set -l color07 '#fbf1c7'
set -l color08 '#fb4934'
set -l color09 '#fe8019'
set -l color0A '#fabd2f'
set -l color0B '#b8bb26'
set -l color0C '#8ec07c'
set -l color0D '#83a598'
set -l color0E '#d3869b'
set -l color0F '#d65d0e'

set -Ux FZF_COLORS "
  --color=bg+:$color01,spinner:$color0C,hl:$color0D
  --color=fg:$color04,header:$color0D,info:$color0A,pointer:$color0C
  --color=marker:$color0C,fg+:$color06,prompt:$color0A,hl+:$color0D
"

set -Ux FZF_DEFAULT_COMMAND 'fd --type f --hidden --follow --exclude .git'
set -Ux FZF_CTRL_T_COMMAND $FZF_DEFAULT_COMMAND
set -Ux FZF_DEFAULT_OPTS $FZF_COLORS' --reverse --height=40%  --bind "ctrl-f:preview-page-down" --bind "ctrl-b:preview-page-up"'
set -Ux FZF_ALT_C_COMMAND 'fd --type d --hidden --follow --exclude .git'