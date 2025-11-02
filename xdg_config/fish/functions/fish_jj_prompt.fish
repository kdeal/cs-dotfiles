function fish_jj_prompt
    # Bail out if jj is unavailable
    if not command -sq jj
        return 1
    end

    # Gather a trimmed description for the current change
    set -l description (jj log --no-graph --ignore-working-copy --color=never --revisions @ \
        --template "truncate_end(40, description.first_line(), \"…\")" 2>/dev/null)
    or return 1

    set description (string trim -- $description)
    if test -n "$description"
        set description (string replace -r '[[:space:]]+' ' ' -- $description)
    else
        set description unnamed
    end

    # Collect working copy change counts via the template system
    set -l wc_lines (jj log --no-graph --ignore-working-copy --color=never --revisions @ \
        --template 'separate("\n",
                diff.files().filter(|file| file.status() == "added").len(),
                diff.files().filter(|file| file.status() == "modified").len(),
                diff.files().filter(|file| file.status() == "removed").len(),
                diff.files().filter(|file| file.status() == "copied").len(),
                diff.files().filter(|file| file.status() == "renamed").len()
            )' 2>/dev/null)
    or return 1

    set -l added (string trim -- $wc_lines[1])
    set -l modified (string trim -- $wc_lines[2])
    set -l removed (string trim -- $wc_lines[3])
    set -l copied (string trim -- $wc_lines[4])
    set -l renamed (string trim -- $wc_lines[5])

    # Determine if there are commits ahead of the working copy commit
    set -l ahead_lines (jj log --no-graph --ignore-working-copy --color=never \
        --revisions 'descendants(@) ~ @' --template 'commit_id\n' 2>/dev/null)
    set -l ahead_count 0
    if test -n "$ahead_lines"
        set -l ahead_entries
        for ahead_commit in $ahead_lines
            set -l trimmed_commit (string trim -- $ahead_commit)
            if test -n "$trimmed_commit"
                set ahead_entries $ahead_entries $trimmed_commit
            end
        end
        if set -q ahead_entries[1]
            set ahead_count (count $ahead_entries)
        end
    end

    # Check for conflicts on the working copy commit
    set -l conflict_flag (jj log --no-graph --ignore-working-copy --color=never --revisions @ \
        --template 'if(conflict, "1", "")' 2>/dev/null)
    set -l has_conflicts 0
    if test -n (string trim -- $conflict_flag)
        set has_conflicts 1
    end

    printf '('

    set_color brwhite
    printf '%s' $description
    set_color normal

    if test $added -gt 0
        set_color green
        printf '+%s' $added
        set_color normal
    end

    if test $modified -gt 0
        set_color blue
        printf '~%s' $modified
        set_color normal
    end

    if test $removed -gt 0
        set_color red
        printf '-%s' $removed
        set_color normal
    end

    if test $copied -gt 0
        set_color magenta
        printf 'c%s' $copied
        set_color normal
    end

    if test $renamed -gt 0
        set_color cyan
        printf 'r%s' $renamed
        set_color normal
    end

    if test $ahead_count -gt 0
        set_color yellow
        printf ' ↑%s' $ahead_count
        set_color normal
    end

    if test $has_conflicts -eq 1
        set_color red
        printf ' ×'
        set_color normal
    end

    printf ')'

    return 0
end
