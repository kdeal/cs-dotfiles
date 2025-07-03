set -e __expand_expanders

# Add a path to a repo
expand-word -p '^repo$' -e 'wkfl repos | sed s,$HOME,~,' -v 'repo-preview {}'

expand-word -p '^gb$' -e 'git branch | sed "s/^\*\s\+\|^\s\+//"' -v 'git l --color=always {}'

expand-word -p '^gt$' -e 'git tag' -v 'git show {1}'

# Have to double escape \\ since they need escaped in this string and in the string when the command is ran
expand-word -p '^gst$' -e 'git stash list --oneline' -v 'git show --color=always {1}' -r 'grep -Po "stash@{\d+}" | sed "s/.*/\"&\"/"'
