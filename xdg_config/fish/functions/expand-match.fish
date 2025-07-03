function expand-match -d 'Matches a pattern against the current word' -a commandargs pattern
    commandline $commandargs | grep -E -q "$pattern"
end
