#!/bin/bash
set -e # Halt on error
set -x # Prints each command to std:err

echo "Starting Ubuntu Setup..."

# -----------------------------------------------------------------------------------
# Ubuntu and Common Dependencies
# -----------------------------------------------------------------------------------
echo "Updating Ubuntu and installing common dependencies..."
sudo apt update && sudo apt upgrade -y
sudo apt install -y \
    curl \
    software-properties-common

# -----------------------------------------------------------------------------------
# Switch to Zsh and Oh-My-Zsh
# -----------------------------------------------------------------------------------
echo "Installing Zsh and Oh-My-Zsh..."
sudo apt install -y zsh
chsh -s $(which zsh)
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# -----------------------------------------------------------------------------------
# Fonts
# -----------------------------------------------------------------------------------
echo "Installing fonts..."
sudo apt install -y \
    fonts-firacode \
    fonts-cantarell

# -----------------------------------------------------------------------------------
# Programming Languages
# -----------------------------------------------------------------------------------
# Java & Maven
echo "Installing Java & Maven..."
sudo apt install -y \
    openjdk-18-jdk \
    maven

# Install nodejs & nvm (for npm)
echo "Installing NodeJS & NVM..."
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash - &&\
sudo apt-get install -y nodejs
curl -O https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh
bash install.sh
rm -rf install.sh

# Pyenv for python version management
# Deps: https://github.com/pyenv/pyenv/wiki#suggested-build-environment
echo "Installing pyenv and global python version..."
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
pyenv install 3.10
pyenv global 3.10

# -----------------------------------------------------------------------------------
# Editors and Tools
# -----------------------------------------------------------------------------------
echo "Installing editors and tools..."

# Terminal Multiplexer
sudo apt install -y tmux

# Ripgrep helps grep within editors
sudo apt install -y ripgrep

# Emacs <3
sudo apt install -y emacs

# Install neovim from source: 
#    https://github.com/neovim/neovim/wiki/Building-Neovim
#    https://github.com/neovim/neovim/wiki/Installing-Neovim#install-from-source
sudo apt-get install ninja-build gettext cmake unzip
git clone https://github.com/neovim/neovim -b release-0.9 neovim
cd neovim
make CMAKE_BUILD_TYPE=Release # RelWithDebInfo
rm -r build/  # clear the CMake cache
make CMAKE_EXTRA_FLAGS="-DCMAKE_INSTALL_PREFIX=$HOME/neovim"
make install
export PATH="$HOME/neovim/bin:$PATH"
cd ..

# -----------------------------------------------------------------------------------
# Setup Directories
# -----------------------------------------------------------------------------------
echo "Creating directories..."

mkdir Work


# -----------------------------------------------------------------------------------
# Setup Symlinks
# -----------------------------------------------------------------------------------
echo "Setting up symlinks..."

ln -s ~/.dotfiles/zshrc ~/.zshrc

ln -s ~/.dotfiles/emacs/ ~/.emacs.d

mkdir -p ~/.config
ln -s ~/.dotfiles/nvim/ ~/.config/nvim


# -----------------------------------------------------------------------------------
# Done! :D
# -----------------------------------------------------------------------------------
echo "Ubuntu setup complete!"

