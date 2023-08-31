#!/bin/bash
set -e # halt on error

echo "Starting Ubuntu Setup..."

# -----------------------------------------------------------------------------------
# Ubuntu and Common Dependencies
# -----------------------------------------------------------------------------------
echo "Updating Ubuntu and installing common dependencies..."
sudo apt update && sudo apt upgrade -y
sudo apt install -y curl software-properties-common

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
sudo apt install -y fonts-firacode fonts-cantarell

# -----------------------------------------------------------------------------------
# Programming Languages
# -----------------------------------------------------------------------------------
# Java & Maven
echo "Installing Java & Maven..."
sudo apt install -y openjdk-18-jdk maven

# Install nodejs & nvm (for npm)
echo "Installing NodeJS & NVM..."
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash - &&\
sudo apt-get install -y nodejs
curl -O https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh
bash install.sh
rm -rf install.sh

# -----------------------------------------------------------------------------------
# Editors and Tools
# -----------------------------------------------------------------------------------
echo "Installing editors and tools..."

sudo apt install -y \
    tmux \              # Terminal Multiplexer
    ripgrep \           # Ripgrep helps grep within editors
    emacs               # Emacs <3

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
# Done! :D
# -----------------------------------------------------------------------------------
echo "Ubuntu setup complete!"

