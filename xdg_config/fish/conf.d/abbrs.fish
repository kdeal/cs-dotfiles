# Updating abbreviations is slow so we should be smart about it and only do it
# when it is required
function update_abbrs
    echo 'Updating abbreviations'

    # Delete old abbreviations
    for abbr in (abbr -l)
        abbr -e $abbr
    end

    # Command specifc
    if command -qs exa
        abbr -a x 'exa'
        abbr -a ls 'exa'
        abbr -a ll 'exa -la'
        abbr -a la 'exa -a'
        abbr -a find 'fd'
    end

    if command -qs rg
        abbr -a grep 'rg'
    end

    if command -qs bat
        abbr -a cat 'bat -p'
    end

    if command -qs nvim
        abbr -a edit 'nvim'
    else
        abbr -a edit 'vim'
    end

    abbr -a ps 'ps -ef | rg'
    abbr -a ta "tmux attach"
    abbr -a cg 'gitroot'
    abbr -a g 'git'
    abbr -a testify 'testify -v --summary '
    abbr -a pydoc 'python -m pydoc '
    abbr -a rsync 'rsync --stats -avz'

    # Make git aliases be fish abbreviations too
    abbr -a ga 'git add'
    abbr -a gau 'git add --update'
    abbr -a gas 'git add-staged'
    abbr -a gaup 'git add --update --patch'
    abbr -a gb 'git branch'
    abbr -a gc 'git commit'
    abbr -a gca 'git commit --amend'
    abbr -a gcf 'git commit --fixup'
    abbr -a gd 'git diff'
    abbr -a gdw 'git diff --word-diff=color'
    abbr -a gdws 'git diff --word-diff=color --cached'
    abbr -a gdsw 'git diff --word-diff=color --cached'
    abbr -a gds 'git diff --cached'
    abbr -a gdt 'git difftool'
    abbr -a gdts 'git difftool --cached'
    abbr -a gdst 'git difftool --cached'
    abbr -a gf 'git fetch origin'
    abbr -a gic 'git-icheckout'
    abbr -a gl 'git l'
    abbr -a gml 'git merge -'
    abbr -a gph 'git push origin'
    abbr -a gpf 'git push --force-with-lease origin'
    abbr -a gpl 'git pull origin'
    abbr -a gr 'git reset'
    abbr -a grb 'git rebase'
    abbr -a grbi 'git rebase -i'
    abbr -a grbc 'git rebase --continue'
    abbr -a grba 'git rebase --abort'
    abbr -a grso 'git reset --hard origin/master'
    abbr -a gs 'git status'
    abbr -a gsh 'git show'
    abbr -a gst 'git stash'
    abbr -a gsw 'git switch'

    abbr -a watch 'watch -c'
end

if status is-interactive
    set -l latest_version (sha1sum ~/.config/fish/conf.d/abbrs.fish | awk '{print $1}')
    if test "$latest_version" != "$__fish_abbr_version"
        update_abbrs
        set -U __fish_abbr_version $latest_version
    end
end