#!/bin/bash

#TODO: Which shebang? #!/usr/bin/env bash  ??

set -e # Halt on error
# set -x # Prints each command to std:err
START_TIME=$(date +%s)

# Ensure we have sudo privileges
sudo -v

# NOTE:
#  A lot of big blocks building stuff from source can just be disabled
#  by removing their ; at the end of the block. This means it doesn't
#  run. Say if you didn't want to build Python. Just remove the ; at the
#  end of its block.

# TODO: Starting to get a lot of stuff here. Might be nice to move all blocks
#  out and then just call them here for a quick overview. I.e: Move install_python
#  to another file, then here just have:
#   install_python
#   install_java
#   ... etc

# -----------------------------------------------------------------------------------
# Set Directories, Paths, Variables & Utils
# -----------------------------------------------------------------------------------
DOWNLOADS="$HOME/Downloads"
[[ ! -d $DOWNLOADS ]] && mkdir -p $DOWNLOADS

BIN="$HOME/bin"
[[ ! -d $BIN ]] && mkdir -p $BIN

WORK="$HOME/Work"
[[ ! -d $WORK ]] && mkdir -p $WORK

# TODO - would be nice to not have this hardcoded.
CONFIG="$HOME/.dotfiles"
[[ ! -d $CONFIG ]] && mkdir -p $CONFIG

source $CONFIG/bashutils.sh
source $CONFIG/config.env

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
{
    stderr "Installing Java & Maven..."
    install_program openjdk-"$JAVA_VERSION"-jdk
    install_program "maven" "mvn"
};


# Install nodejs & nvm (for npm)
{
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
};

# Install Pyenv and Python
{
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
};

# Rust
{
    stderr "Installing Rust and its developer tools..."

    if command_exists rustup; then
	stderr "Rust already installed"
    else
	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
	source "$HOME/.cargo/env"
	rustup component add rust-analyzer
	rustup component add rust-src
	cargo install cargo-edit
    fi
};

# Zig
{
    stderr "Installing Zig and its developer tools..."

    if command_exists zig; then
	stderr "Zig already installed"
    else
	sudo apt install -y \
	    clang \
	    cmake \
	    libclang-17-dev \
	    liblld-17-dev \
	    lld-17 \
	    llvm-17 \
	    llvm-17-dev

	git clone https://github.com/ziglang/zig.git $DOWNLOADS/zig
	cd $DOWNLOADS/zig

	git checkout $ZIG_COMMIT
	mkdir -p build && cd build

	cmake .. -DCMAKE_INSTALL_PREFIX="/usr/local/zig/$ZIG_VERSION" -DCMAKE_BUILD_TYPE=Release
	make
	sudo make install
	ln -s "/usr/local/zig/$ZIG_VERSION/bin/zig" "$BIN/zig"

	# Zig Language Server (zls)
	git clone https://github.com/zigtools/zls $DOWNLOADS/zls
	cd $DOWNLOADS/zls

	zig build -Doptimize=ReleaseSafe
	ln -s "$DOWNLOADS/zls/zig-out/bin/zls" "$BIN/zls"

	cd $CONFIG
    fi
};

# Direnv
echo "Installing direnv..."
install_program direnv

# -----------------------------------------------------------------------------------
# Editors and Tools
# -----------------------------------------------------------------------------------
stderr "-------------------- Installing Editors & Tools ----------------------------"

# TODO: Add -y flags or switch to install functions in this section to avoid disk
#  space prompts.

# Terminal Multiplexer
install_program tmux

# Ripgrep helps grep within editors
install_program ripgrep "rg"

# Tree Sitter
{
    stderr "Installing tree sitter"

    if [[ -e /usr/local/lib/libtree-sitter.a ]]; then
	stderr "Treesitter library already installed"
    else
	git clone https://github.com/tree-sitter/tree-sitter.git $DOWNLOADS/tree-sitter
	cd $DOWNLOADS/tree-sitter
	sudo make
	sudo make install
	cd $CONFIG
    fi
};

# Tree Sitter Bulk Grammars
# (https://git.savannah.gnu.org/cgit/emacs.git/tree/admin/notes/tree-sitter/starter-guide?h=feature/tree-sitter#n56)
# In emacs: Set treesit-extra-load-path to the dist/ directory where these dynamic libraries end up.
# Or add them to your /usr/local/lib which is where your system expects them to be.
{
    stderr "Installing tree sitter grammars"

    git clone https://github.com/casouri/tree-sitter-module.git $DOWNLOADS/tree-sitter-grammars
    cd $DOWNLOADS/tree-sitter-grammars
    JOBS=8 ./batch.sh
    ln -s "$DOWNLOADS/tree-sitter-grammars/dist" "$BIN/tree-sitter-grammars"
    cd $CONFIG
}

# TODO not sure if this is required (confirm next time you do a reinstall)
#  stuck between tree-sitter and emacs before this.
# sudo ldconfig 
# ldconfig -v | grep /usr/local/lib

# Install Emacs from source <3
{
    if command_exists "emacs"; then
	stderr "Emacs already installed"
    else
	mkdir $DOWNLOADS/emacs$EMACS_VERSION
	cd $DOWNLOADS/emacs$EMACS_VERSION
	git clone --depth 1 -b $EMACS_BRANCH https://git.savannah.gnu.org/git/emacs.git ./

	# Get required packages
	sudo apt-get update
	sudo apt-get install \
	    autoconf \
	    texinfo \
	    libgtk-3-dev \
	    libxaw7-dev \
	    libgif-dev

	# Extra required packages
	sudo apt-get install libgccjit-11-dev libgccjit-11-doc # For native-compilation
	sudo apt-get install libjansson4 libjansson-dev # For fast JSON
	sudo apt install libtool libtool-bin # Needed for vterm

	# Configure and build
	./autogen.sh
	./configure --with-native-compilation \
		    --with-json \
		    --with-mailutils \
		    --without-compress-install \
		    --with-tree-sitter

	sudo make -j16

	# ~/Downloads/emacs29/src/emacs is now executable
	$DOWNLOADS/emacs$EMACS_VERSION/src/emacs --version

	sudo make install
	cd $CONFIG
    fi
};

# Install neovim from source:
#    https://github.com/neovim/neovim/wiki/Building-Neovim
#    https://github.com/neovim/neovim/wiki/Installing-Neovim#install-from-source
{
    if command_exists "nvim"; then
	stderr "Neovim already installed"
    else
	mkdir $DOWNLOADS/neovim$NEOVIM_VERSION
	cd $DOWNLOADS/neovim$NEOVIM_VERSION

	sudo apt-get install -y ninja-build gettext cmake unzip

	git clone https://github.com/neovim/neovim -b $NEOVIM_BRANCH ./
	make CMAKE_BUILD_TYPE=Release # RelWithDebInfo
	rm -r build/  # clear the CMake cache
	make CMAKE_EXTRA_FLAGS="-DCMAKE_INSTALL_PREFIX=$BIN/neovim$NEOVIM_VERSION"
	make install
	cd $CONFIG
    fi
};

# --- Misc ---

# TODO
mkdir -p ~/Org # TODO This is a private git directory. How should I handle in my public repo?

# -----------------------------------------------------------------------------------
# Setup Symlinks
# -----------------------------------------------------------------------------------
stderr "--------------------- Setting Up Final Symlinks ----------------------------"

# Zsh Config
symlink ~/.dotfiles/ubuntu/zshrc ~/.zshrc

# Emacs Config
symlink ~/.dotfiles/emacs ~/.emacs.d
# symlink -f ~/.dotfiles/doom ~/.emacs.d (For using doom)
# Can also direct emacs29 with --init-directory

# Neovim Config
mkdir -p ~/.config
symlink ~/.dotfiles/nvim ~/.config/nvim

# -----------------------------------------------------------------------------------
# Doom Emacs
# -----------------------------------------------------------------------------------
stderr "--------------------- Setting up Doom Emacs --------------------------------"

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

