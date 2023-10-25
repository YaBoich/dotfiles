#!/bin/bash

set -e # Halt on error
# set -x # Prints each command to std:err

START_TIME=$(date +%s)

sudo -v # Ensure we have sudo privileges

# ------------------------------------------------------------------------------------
# Set Directories, Paths, Variables & Utils
# ------------------------------------------------------------------------------------
export DOWNLOADS="$HOME/Downloads"
[[ ! -d $DOWNLOADS ]] && mkdir -p $DOWNLOADS

export BIN="$HOME/bin"
[[ ! -d $BIN ]] && mkdir -p $BIN

export WORK="$HOME/Work"
[[ ! -d $WORK ]] && mkdir -p $WORK

# TODO - would be nice to not have this hardcoded.
export CONFIG="$HOME/.dotfiles"
[[ ! -d $CONFIG ]] && mkdir -p $CONFIG

source $CONFIG/bashutils.sh
source $CONFIG/config.env
source $CONFIG/ubuntu/installers.sh

stderr "============================================================================="
stderr "======================= Starting Ubuntu Setup ==============================="
stderr "============================================================================="

cd $CONFIG

# ------------------------------------------------------------------------------------
# Ubuntu and Common Dependencies
# ------------------------------------------------------------------------------------
stderr "------------- Updating Ubuntu and installing common dependencies ------------"
sudo apt update && sudo apt upgrade -y

install_program curl
install_program software-properties-common

# ------------------------------------------------------------------------------------
# Switch to Zsh and Oh-My-Zsh
# ------------------------------------------------------------------------------------
stderr "--------------------- Installing Zsh & Oh-My-Zsh ----------------------------"
install_program zsh

if [ "$SHELL" != "$(which zsh)" ]; then
    chsh -s $(which zsh)
fi
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    RUNZSH=no sh -c \
	"$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# ------------------------------------------------------------------------------------
# Fonts
# ------------------------------------------------------------------------------------
stderr "-------------------------- Installing fonts ---------------------------------"

# Fonts don't have a command
install_package "fonts-firacode" "fc-list | grep 'Fira Code'"
install_package "fonts-cantarell" "fc-list | grep 'Cantarell'"

# ------------------------------------------------------------------------------------
# Programming Languages
# ------------------------------------------------------------------------------------
stderr "------------------------ Installing Languages -------------------------------"

# install_java                                      # Java & Maven
install_nodejs                                    # Install nodejs & nvm (for npm)
install_python                                    # Install Pyenv and Python
# install_rust                                      # Install Rust and Rust Analyzer
install_zig                                       # Zig and Zls (from source)

install_program direnv                            # Direnv

# ------------------------------------------------------------------------------------
# Editors and Tools
# ------------------------------------------------------------------------------------
stderr "-------------------- Installing Editors & Tools -----------------------------"

# TODO: Add -y flags or switch to install functions in this section to avoid disk
#  space prompts.

install_program tmux                              # Terminal Multiplexer
install_program ripgrep "rg"                      # The best (rip)grepper

install_tree_sitter                               # Tree Sitter
install_tree_sitter_grammars                      # Tree Sitter Bulk Grammars

# TODO: not sure if this is required (confirm next time you do a reinstall)
#       stuck between tree-sitter and emacs before this.
# sudo ldconfig 
# ldconfig -v | grep /usr/local/lib

install_emacs                                     # Emacs from source <3
install_neovim                                    # Neovim from source

# ------------------------------------------------------------------------------------
# Misc Directories
# ------------------------------------------------------------------------------------

mkdir -p ~/Org # TODO: This is a private git directory. How should I handle in my
               #       public repo?
mkdir -p ~/.config # Ensure .config exists for whatever needs it

# ------------------------------------------------------------------------------------
# Setup Symlinks
# ------------------------------------------------------------------------------------
stderr "--------------------- Setting Up Final Symlinks -----------------------------"

symlink ~/.dotfiles/ubuntu/zshrc ~/.zshrc         # Zsh Config
symlink ~/.dotfiles/emacs        ~/.emacs.d       # Emacs Config
symlink ~/.dotfiles/nvim         ~/.config/nvim   # Neovim Config

# symlink -f ~/.dotfiles/doom ~/.emacs.d (For using doom)
# Can also direct emacs29 with --init-directory

# ------------------------------------------------------------------------------------
# Doom Emacs (Not using since building Emacs29 from source)
# ------------------------------------------------------------------------------------
# stderr "--------------------- Setting up Doom Emacs ---------------------------------"

# (https://github.com/doomemacs/doomemacs/blob/master/docs/getting_started.org)
## if command_exists "$HOME/.emacs.d/bin/doom"; then
##     stderr "Doom Emacs already setup."
## 
## else
##     # Doom Emacs Dependancies
##     install_program fd-find "fdfind"
## 
##     # Point .doom.d to my config
##     symlink ~/.dotfiles/doom ~/.doom.d
## 
##     git clone --depth 1 https://github.com/doomemacs/doomemacs ~/.emacs.d/
## 
##     ~/.emacs.d/bin/doom sync
##     ~/.emacs.d/bin/doom env
##     # TODO currently not working. Need to do manually in emacs
##     # emacs --batch -f nerd-icons-install-fonts
## 
##     stderr "Setup doom emacs."
## fi

# ------------------------------------------------------------------------------------
# Done! :D
# ------------------------------------------------------------------------------------
stderr "============================= All Done! :D =================================="

END_TIME=$(date +%s)
ELAPSED_TIME=$((END_TIME - START_TIME))
MINUTES=$((ELAPSED_TIME / 60))
SECONDS=$((ELAPSED_TIME % 60))
stderr "Finished setup in: $MINUTES minutes and $SECONDS seconds"

zsh
source ~/.zshrc

