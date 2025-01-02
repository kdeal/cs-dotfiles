function update_abbrs
    # Command specifc
    if command -qs eza
        abbr -ga ls eza
        abbr -ga ll 'eza -la'
        abbr -ga la 'eza -a'
    end

    if command -qs fd
        abbr -ga find fd
    end

    if command -qs rg
        abbr -ga grep rg
    end

    if command -qs bat
        abbr -ga cat 'bat -p'
    end

    if command -qs nvim
        abbr -ga edit nvim
    else
        abbr -ga edit vim
    end

    abbr -ga ps 'ps -ef | rg'
    abbr -ga ta "tmux attach"
    abbr -ga cg gitroot
    abbr -ga g git
    abbr -ga testify 'testify -v --summary '
    abbr -ga pydoc 'python -m pydoc '
    abbr -ga rsync 'rsync --stats -avz'

    # Make git aliases be fish abbreviations too
    abbr -ga ga 'git add'
    abbr -ga gau 'git add --update'
    abbr -ga gas 'git add-staged'
    abbr -ga gaup 'git add --update --patch'
    abbr -ga gb 'git branch'
    abbr -ga gc 'git commit'
    abbr -ga gca 'git commit --amend'
    abbr -ga gcf 'git commit --fixup'
    abbr -ga gd 'git diff'
    abbr -ga gdw 'git diff --word-diff=color'
    abbr -ga gdws 'git diff --word-diff=color --cached'
    abbr -ga gdsw 'git diff --word-diff=color --cached'
    abbr -ga gds 'git diff --cached'
    abbr -ga gdt 'git difftool'
    abbr -ga gdts 'git difftool --cached'
    abbr -ga gdst 'git difftool --cached'
    abbr -ga gf 'git fetch origin'
    abbr -ga gic git-icheckout
    abbr -ga gl 'git l'
    abbr -ga gml 'git merge -'
    abbr -ga gph 'git push origin'
    abbr -ga gpf 'git push --force-with-lease origin'
    abbr -ga gpl 'git pull origin'
    abbr -ga gr 'git reset'
    abbr -ga grb 'git rebase'
    abbr -ga grbi 'git rebase -i'
    abbr -ga grbc 'git rebase --continue'
    abbr -ga grba 'git rebase --abort'
    abbr -ga grso 'git reset --hard origin/master'
    abbr -ga gs 'git status'
    abbr -ga gsh 'git show'
    abbr -ga gst 'git stash'
    abbr -ga gsw 'git switch'

    abbr -ga watch 'watch -c'
end

if status is-interactive
    update_abbrs
end
