# ==============================================================================
# A collection of useful bash utilities
# ==============================================================================

# Output
# ------------------------------------------------------------------------------

stdout() {
    # Outputs to Std:Out
    echo "$@"
}

stderr() {
    # Outputs to Std:Err
    echo "$@" 1>&2
}

# Packages and Installations
# ------------------------------------------------------------------------------

command_exists() {
    # command_exists(command)
    #   Checks for the existance of the given command. Useful for checking if
    #   certain tools are installed on your system.
    # Example: if command_exists "npm"; then... else... fi
    command -v "$1" >/dev/null 2>&1
}

command_has_output() {
    # command_has_output(check_command)
    #   Evaluates the provided command and returns true if the command produces output.
    #   This is useful for checking the presence of things based on custom commands.
    local check_command="$1"
    eval "$check_command" &> /dev/null
}

# Files and Folders
# ------------------------------------------------------------------------------

# TODO consider having a single backup folder rather than putting backups all 
#  over the place
symlink() {
    # symlink(source, target)
    # flags: --force / -f : Force creation of symlink
    #   Creates a symlink, handling the following scenarios:
    #   - target doesn't exist 
    #       -> create the symlink
    #   - target exists as a file/dir
    #       -> backup, remove, create symlink
    #   - target is symlink already, pointing at source 
    #       -> do nothing
    #   - target is symlink already, pointing somewhere else 
    #       -> throw an error UNLESS --force flag is provided.
    # @param source is the thing being linked to
    # @param target is the "fake" file/dir linking to source

    local force=false

    # Check for flags
    while [[ "$1" =~ ^- ]]; do
        case "$1" in
            --force|-f) force=true; shift ;;
            *) stderr "Unknown flag: $1"; return 1 ;;
        esac
    done

    local source="$1"
    local target="$2"

    # Check if the target already exists
    if [[ -e "$target" && ! -L "$target" ]]; then
        # Create a backup for real files or directories
        local backup="${target}.$(date +%Y%m%d%H%M%S).backup"
        mv "$target" "$backup"
        stderr "Existing file/directory $target backed up to $backup"
    elif [[ -L "$target" ]]; then
        # Check where the symlink is pointing
        local current_link=$(readlink "$target")
        if [[ "$current_link" == "$source" ]]; then
            stderr "Symlink $target already points to $source. Doing nothing."
            return
        else
	    if [[ "$force" = false ]]; then
                stderr "Error: $target points to $current_link, not $source."
                return 1
            else
                stderr "$target will be overridden due to --force flag."
                local backup="${target}.$(date +%Y%m%d%H%M%S).backup"
                mv "$target" "$backup"
                stderr "Existing symlink $target backed up to $backup"
            fi
        fi
    fi

    # Create or replace the symlink
    ln -sf "$source" "$target"
    stderr "Created or replaced symlink: $target -> $source"
}

#------------------------------ Functions -------------------------------------------

# Single command to extract compressed files
extract() {
    if [ -f $1 ]; then
        case $1 in
            *.tar.bz2)  tar xvjf $1    ;;
            *.tar.gz)   tar xvzf $1    ;;
            *.bz2)      bunzip2 $1     ;;
            *.rar)      unrar x $1     ;;
            *.gz)       gunzip $1      ;;
            *.tar)      tar xvf $1     ;;
            *.tbz2)     tar xvjf $1    ;;
            *.tgz)      tar xvzf $1    ;;
            *.zip)      unzip $1       ;;
            *.Z)        uncompress $1  ;;
            *.7z)       7z x $1        ;;
            *)          echo "don't know how to extract '$1'..." ;;
        esac
    else
        echo "'$1' is not a valid file!"
    fi
}

# Create a new directory and navigate to it
mkd() {
    mkdir -p "$@" && cd "$@"
}
