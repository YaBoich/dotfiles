#!/bin/bash
set -e # Halt on error
# set -x # Prints each command to std:err
START_TIME=$(date +%s)

# -----------------------------------------------------------------------------------
# Set Variables & Utils
# -----------------------------------------------------------------------------------
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
OSX_DIR="$SCRIPT_DIR/osx"

source $SCRIPT_DIR/bashutils.sh
source $SCRIPT_DIR/config.env

brew_install_cask() {
    # Install a cask doing nothing if it already exists
    local cask_name="$1"
    if brew list --cask | grep -q "$cask_name"; then
        stderr "$cask_name is already installed."
    else
        brew install --cask "$cask_name"
        stderr "Installed $cask_name."
    fi
}

stderr "------------------------- Starting OSX Setup -------------------------------"

# -----------------------------------------------------------------------------------
# Install Homebrew
# -----------------------------------------------------------------------------------
stderr "------------------------- Installing Homebrew ------------------------------"
install_brew() { 
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
}
idem_install "brew" install_brew

# -----------------------------------------------------------------------------------
# Switch to Zsh and Oh-My-Zsh
# -----------------------------------------------------------------------------------
stderr "---------------------- Installing Zsh and Oh-My-Zsh ------------------------"
brew install zsh
if ! grep -q "$(which zsh)" /etc/shells; then
    stderr "Adding zsh to the list of shells"
    sudo sh -c "echo $(which zsh) >> /etc/shells"
fi
if [ "$SHELL" != "$(which zsh)" ]; then
    stderr "Changing the shell to zsh"
    chsh -s $(which zsh)
fi
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    stderr "Installing Oh-My-Zsh"
    RUNZSH=no sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# -----------------------------------------------------------------------------------
# Install fonts
# -----------------------------------------------------------------------------------
stderr "-------------------------- Installing fonts --------------------------------"
brew tap homebrew/cask-fonts 
brew_install_cask font-cantarell
brew_install_cask font-fira-code

# -----------------------------------------------------------------------------------
# Programming Languages
# -----------------------------------------------------------------------------------
stderr "------------------------ Installing Languages ------------------------------"

# Java & Maven
stderr "Installing Java & Maven..."
brew install \
    openjdk@"$JAVA_VERSION" \
    maven

# Install Node.js & NVM
stderr "Installing NodeJS & NVM..."
brew install nvm
mkdir -p ~/.nvm # creating working dir if it doesn't exist
export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # load nvm
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # load nvm bash_completion - TODO probably not required here, only in zshrc
nvm install "$NODE_VERSION"
nvm use "$NODE_VERSION"

# Pyenv & Python
stderr "Installing pyenv and global python version..."
brew install pyenv
if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init --path)"
fi
if ! pyenv versions | grep -q "$PYTHON_VERSION"; then
    pyenv install "$PYTHON_VERSION"
else
    stderr "Python $PYTHON_VERSION is already installed."
fi

if [[ $(pyenv version-name) != "$PYTHON_VERSION" ]]; then
    pyenv global "$PYTHON_VERSION"
else
    stderr "Python $PYTHON_VERSION is already set as the global version."
fi

# Rust
stderr "Installing Rust and its developer tools..."
brew install rustup
if command -v rustc 1>/dev/null 2>&1; then
    rustup-init -y
    rustup component add rust-analyzer
    rustup component add rust-src
    cargo install cargo-edit
fi

# Direnv
stderr "Installing direnv..."
brew install direnv

# -----------------------------------------------------------------------------------
# Editors and Tools
# -----------------------------------------------------------------------------------
stderr "-------------------- Installing Editors & Tools ----------------------------"

# Iterm2
brew_install_cask iterm2
defaults write com.googlecode.iterm2 PrefsCustomFolder -string "$OSX_DIR/iterm2/"
defaults write com.googlecode.iterm2 LoadPrefsFromCustomFolder -bool true

# Emacs <3
brew_install_cask emacs

# Neovim (brew seems to install v0.9+ by default)
brew install neovim

# -----------------------------------------------------------------------------------
# OSX Utilities
# -----------------------------------------------------------------------------------
stderr "---------------------- Installing OSX Utils --------------------------------"

# Install GNU coreutils (https://apple.stackexchange.com/questions/4812/how-to-get-the-fully-resolved-path-of-a-symbolic-link-in-terminal)
brew install coreutils

# Clipboard manager (alternative is clipy)
brew_install_cask flycut
symlink \
    $OSX_DIR/flycut/com.generalarcade.flycut.plist \
    ~/Library/Containers/com.generalarcade.flycut/Data/Library/Preferences/com.generalarcade.flycut.plist

# Window manager
brew_install_cask rectangle
symlink \
    $OSX_DIR/rectangle/com.knollsoft.Rectangle.plist \
    ~/Library/Preferences/com.knollsoft.Rectangle.plist

# -----------------------------------------------------------------------------------
# Setup Symlinks
# -----------------------------------------------------------------------------------
stderr "--------------------- Setting Up Final Symlinks ----------------------------"

# Emacs config
symlink $SCRIPT_DIR/emacs $HOME/.emacs.d

# Neovim config
mkdir -p $HOME/.config
symlink $SCRIPT_DIR/nvim $HOME/.config/nvim

# Zsh config
symlink $SCRIPT_DIR/zsh/zshrc $HOME/.zshrc

# -----------------------------------------------------------------------------------
# Create Directories
# -----------------------------------------------------------------------------------
stderr "--------------------- Creating Directories ---------------------------------"

mkdir -p ~/Work
mkdir -p ~/Org

# -----------------------------------------------------------------------------------
# All Done! :D
# -----------------------------------------------------------------------------------
stderr "============================= All Done! :D ================================="

END_TIME=$(date +%s)
ELAPSED_TIME=$((END_TIME - START_TIME))
MINUTES=$((ELAPSED_TIME / 60))
SECONDS=$((ELAPSED_TIME % 60))
stderr "Finished setup in: $MINUTES minutes and $SECONDS seconds"

zsh
source $HOME/.zshrc

