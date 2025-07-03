function expand-word -d 'Define a word expansion'
    set -l help "Define a word expansion.
Options
  -c, --condition    Function whose return value determines when the expansion should be run
  -e, --expander     Function or string to expand the matching word with
  -h, --help         Show this help message
  -p, --pattern      A regular expression condition the word must match
  -r, --reduce       Command to be ran after the expand has happened. This lets fzf on one thing and reduce it after selection
  -v, --preview      Command to run as the fzf preview
"

    argparse --name expand-word --exclusive 'condition,pattern' \
        h/help 'c/condition=' 'e/expander=' 'p/pattern=' 'v/preview=' \
        'r/reduce=' -- $argv

    if [ $status -gt 0 ]
        return 1
    end

    if set -q _flag_help
        echo "$help"
        return 0
    end

    if set -q _flag_pattern
        set _flag_condition "expand-match -t '$_flag_pattern'"
    end

    if not set -q _flag_condition
        echo "Expansions must have a condition" >&2
        return 1
    end

    if not set -q _flag_expander
        echo "You must specify an expander" >&2
        return 1
    end

    if not set -q _flag_reduce
        set _flag_reduce cat
    end

    set -g __expand_expanders $__expand_expanders "$_flag_condition
$_flag_expander
$_flag_preview
$_flag_reduce"
end
