# Disable file completion for positional arguments
complete -c cmd-install -f

# Options
complete -c cmd-install -s h -l help -d "Show help and exit"
complete -c cmd-install -l arch -r -d "Target architecture (amd64/x86_64/x64 or arm64/aarch64)"
complete -c cmd-install -l config -r -F -d "TOML config path"
complete -c cmd-install -l list -d "List available commands and exit"
complete -c cmd-install -l arch -xa "amd64 x86_64 x64 arm64 aarch64"

# Dynamic list of commands
complete -c cmd-install -fa '(cmd-install --list 2>/dev/null)'
