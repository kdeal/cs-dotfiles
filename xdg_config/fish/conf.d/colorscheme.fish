set -U fish_color_cwd yellow
set -U fish_color_cwd_root red
set -U fish_color_escape cyan
set -U fish_color_history_current cyan
set -U fish_color_host blue
set -U fish_color_match cyan
set -U fish_color_normal normal
set -U fish_color_operator cyan
set -U fish_color_search_match --background=purple
set -U fish_color_selection --background=purple
set -U fish_color_status red
set -U fish_color_user green
set -U fish_color_valid_path --underline

if true
    # Dark
    set -U fish_color_autosuggestion 586e75
    set -U fish_color_command 93a1a1
    set -U fish_color_comment brgreen
    set -U fish_color_end blue
    set -U fish_color_error red
    set -U fish_color_param 657b83
    set -U fish_color_quote yellow
    set -U fish_color_redirection brmagenta
else
    # Light
    set -U fish_color_autosuggestion 93a1a1
    set -U fish_color_command 586e75
    set -U fish_color_comment 93a1a1
    set -U fish_color_end 268bd2
    set -U fish_color_error dc322f
    set -U fish_color_param 839496
    set -U fish_color_quote yellow
    set -U fish_color_redirection 6c71c4
end

# Pager colors
set -U fish_pager_color_completion normal
set -U fish_pager_color_description 555 yellow
set -U fish_pager_color_prefix cyan
set -U fish_pager_color_progress cyan

# Git colors
set -U __fish_git_prompt_color_branch brred
set -U __fish_git_prompt_color_prefix brred
set -U __fish_git_prompt_color_suffix brred

# Emulates vim's cursor shape behavior
# Set the normal and visual mode cursors to a block
set fish_cursor_default block
# Set the insert mode cursor to a line
set fish_cursor_insert line
# Set the replace mode cursors to an underscore
set fish_cursor_replace_one underscore
set fish_cursor_replace underscore
# Set the external cursor to a line. The external cursor appears when a command is started.
# The cursor shape takes the value of fish_cursor_default when fish_cursor_external is not specified.
set fish_cursor_external block

# Have to force cursor because it doesn't detect ghostty
set fish_vi_force_cursor true
