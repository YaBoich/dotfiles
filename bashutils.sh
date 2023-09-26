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

idem_install() {
    # idem_install(command, install_function)
    #   A generic idempotent install, takes a command or tool and its 
    #   installation function.
    #   Here you can cater the installation function per OS or package manager.
    # Example: idem_install "npm" install_npm
    #   Where "install_npm" is a function containing something like:
    #     "brew install npm"
    local check_command="$1"
    local install_function="$2"

    if command_exists "$check_command"; then
        stderr "$check_command already installed."
    else
        $install_function
        stderr "Installed $check_command."
    fi
}

# Files and Folders
# ------------------------------------------------------------------------------

# TODO consider having a single backup folder rather than putting backups all 
#  over the place
symlink() {
    # symlink(source, target)
    #   Creates a symlink, handling the following scenarios:
    #   - target doesn't exist 
    #       -> create the symlink
    #   - target exists as a file/dir
    #       -> backup, remove, create symlink
    #   - target is symlink already, pointing at source 
    #       -> do nothing
    #   - target is symlink already, pointing somewhere else 
    #       -> throw an error
    # @param source is the thing being linked to
    # @param target is the "fake" file/dir linking to source
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
            stderr "Error: $target points to $current_link, not $source."
            return 1  # Exits with an error status
        fi
    fi

    # Create or replace the symlink
    ln -sf "$source" "$target"
    stderr "Created or replaced symlink: $target -> $source"
}
