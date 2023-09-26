#!/bin/bash
set -e # Halt on error
# set -x # Prints each command to std:err
START_TIME=$(date +%s)

# Ensure we have sudo privileges
sudo -v

# -----------------------------------------------------------------------------------
# Set Variables & Utils
# -----------------------------------------------------------------------------------
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source $SCRIPT_DIR/bashutils.sh
source $SCRIPT_DIR/config.env

install_program() {
    # install_program(program_name, command_name: optional)
    #   If the program isn't already installed, it runs the provided install command.
    #   If command_name isn't provided, assumes it's the same as the program name.
    local program_name="$1"
    local command_name="${2:-$1}"

    if command_exists "$command_name"; then
        stderr "$program_name is already installed."
    else
        stderr "Installing $program_name..."
	sudo apt install -y "$program_name"
    fi
}

install_package() {
    # install_package(package_name, check_command)
    #   Installs a package if the check_command indicates it's not already installed.
    #   Useful for things like fonts that aren't executable.
    local package_name="$1"
    local check_command="$2"

    if command_has_output "$check_command"; then
        stderr "$package_name is already installed."
    else
        stderr "Installing $package_name..."
        sudo apt install -y "$package_name"
    fi
}

stderr "----------------------- Starting Ubuntu Setup ------------------------------"

# -----------------------------------------------------------------------------------
# Ubuntu and Common Dependencies
# -----------------------------------------------------------------------------------
stderr "Updating Ubuntu and installing common dependencies..."
sudo apt update && sudo apt upgrade -y

install_program curl
install_program software-properties-common

# -----------------------------------------------------------------------------------
# Switch to Zsh and Oh-My-Zsh
# -----------------------------------------------------------------------------------
stderr "--------------------- Installing Zsh & Oh-My-Zsh ---------------------------"
install_program zsh

if [ "$SHELL" != "$(which zsh)" ]; then
    chsh -s $(which zsh)
fi
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    RUNZSH=no sh -c \
	"$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# -----------------------------------------------------------------------------------
# Fonts
# -----------------------------------------------------------------------------------
stderr "-------------------------- Installing fonts --------------------------------"

# Fonts don't have a command
install_package "fonts-firacode" "fc-list | grep 'Fira Code'"
install_package "fonts-cantarell" "fc-list | grep 'Cantarell'"

# -----------------------------------------------------------------------------------
# Programming Languages
# -----------------------------------------------------------------------------------
stderr "------------------------ Installing Languages ------------------------------"

# Java & Maven
stderr "Installing Java & Maven..."
install_program openjdk-"$JAVA_VERSION"-jdk
install_program "maven" "mvn"

# Install nodejs & nvm (for npm)
stderr "Installing NVM & NodeJS..."
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

if command_exists nvm && [ "$(nvm --version)" = "$NVM_VERSION" ]; then
    stderr "NVM version $NVM_VERSION is already installed."
else
    stderr "Installing NVM version $NVM_VERSION..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v"$NVM_VERSION"/install.sh | bash
    mkdir -p ~/.nvm # creating working dir if it doesn't exist
    # Reload the shell configuration to make sure nvm is available
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
fi

nvm install "$NODE_VERSION"
nvm use "$NODE_VERSION"

# Pyenv for python version management
# Deps: https://github.com/pyenv/pyenv/wiki#suggested-build-environment
stderr "Installing pyenv and global python version..."
if command_exists "pyenv"; then
    stderr "Pyenv already installed"
else
    sudo apt install -y \
	build-essential \
	libssl-dev \
	zlib1g-dev \
	libbz2-dev \
	libreadline-dev \
	libsqlite3-dev \
	libncursesw5-dev \
	tk-dev \
	libxml2-dev \
	libxmlsec1-dev \
	libffi-dev \
	liblzma-dev

    curl https://pyenv.run | bash

    # Add pyenv to PATH and initialize
    export PATH="$HOME/.pyenv/bin:$PATH"
    command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init --path)"
    eval "$(pyenv virtualenv-init -)"
fi

if command_exists python; then
    installed_version=$(python --version 2>&1 | awk '{print $2}' | cut -d"." -f1,2)
    if [ "$installed_version" == "$PYTHON_VERSION" ]; then
	echo "Python version $PYTHON_VERSION already installed."
    else
	pyenv install "$PYTHON_VERSION"
	pyenv global "$PYTHON_VERSION"
    fi
else
    pyenv install "$PYTHON_VERSION"
    pyenv global "$PYTHON_VERSION"
fi

# Direnv
echo "Installing direnv..."
install_program direnv

# -----------------------------------------------------------------------------------
# Editors and Tools
# -----------------------------------------------------------------------------------
stderr "-------------------- Installing Editors & Tools ----------------------------"

# Terminal Multiplexer
install_program tmux

# Ripgrep helps grep within editors
install_program ripgrep "rg"

# Emacs <3
install_program emacs

# Install neovim from source:
#    https://github.com/neovim/neovim/wiki/Building-Neovim
#    https://github.com/neovim/neovim/wiki/Installing-Neovim#install-from-source
if command_exists "nvim"; then
    stderr "Neovim already installed"
else
    sudo apt-get install ninja-build gettext cmake unzip
    git clone https://github.com/neovim/neovim -b release-0.9 neovim
    cd neovim
    make CMAKE_BUILD_TYPE=Release # RelWithDebInfo
    rm -r build/  # clear the CMake cache
    make CMAKE_EXTRA_FLAGS="-DCMAKE_INSTALL_PREFIX=$HOME/neovim"
    make install
    export PATH="$HOME/neovim/bin:$PATH"
    cd ..
    rm -rf neovim/
fi

# -----------------------------------------------------------------------------------
# Setup Directories
# -----------------------------------------------------------------------------------
stderr "--------------------- Creating Directories ---------------------------------"

mkdir -p ~/Work
mkdir -p ~/Org

# -----------------------------------------------------------------------------------
# Setup Symlinks
# -----------------------------------------------------------------------------------
stderr "--------------------- Setting Up Final Symlinks ----------------------------"

rm -rf ~/.zshrc
ln -s ~/.dotfiles/ubuntu/zshrc ~/.zshrc

rm -rf ~/.emacs.d
ln -s ~/.dotfiles/emacs ~/.emacs.d

mkdir -p ~/.config
rm -rf ~/.config/nvim
ln -s ~/.dotfiles/nvim ~/.config/nvim

# -----------------------------------------------------------------------------------
# Done! :D
# -----------------------------------------------------------------------------------
stderr "============================= All Done! :D ================================="

END_TIME=$(date +%s)
ELAPSED_TIME=$((END_TIME - START_TIME))
MINUTES=$((ELAPSED_TIME / 60))
SECONDS=$((ELAPSED_TIME % 60))
stderr "Finished setup in: $MINUTES minutes and $SECONDS seconds"

zsh
source ~/.zshrc

