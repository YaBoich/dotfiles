#!/bin/bash

# ====================================================================================
# A collection of functions that install software, languages & tools.
#
# These do not work in isolation, they are part of my personal config. They are not
# pure functions. They assume certain environment variables such as $DOWNLOADS, $BIN,
# and $CONFIG, and also have specific requirement. Each will validate its required
# environment.
# ====================================================================================

# Checks the existence of provided environment variables and exits if any are unset.
# Usage:
#     check_env VAR1 VAR2 VAR3 ...
# Example:
#     check_env "DOWNLOADS" "BIN" "CONFIG"
#     check_env "JAVA_VERSION"
check_env() {
    for var in "$@"; do
        if [[ -z "${!var}" ]]; then
            echo "Error: \$$var is not set. Cannot proceed without required env."
            exit 1
        fi
    done
}

# Ensure required environment
check_env "HOME" "DOWNLOADS" "BIN" "CONFIG"

source $CONFIG/bashutils.sh
source $CONFIG/config.env

# ------------------------------------------------------------------------------------
# Utils
# ------------------------------------------------------------------------------------

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

# ------------------------------------------------------------------------------------
# Programming Languages and their Tooling
# ------------------------------------------------------------------------------------

# Java & Maven
install_java() {
    stderr "Installing Java & Maven..."
    check_env "JAVA_VERSION"

    install_program openjdk-"$JAVA_VERSION"-jdk
    install_program "maven" "mvn"
}

# Install nodejs & nvm (for npm)
install_nodejs() {
    stderr "Installing NVM & NodeJS..."
    check_env "NVM_VERSION" "NODE_VERSION"

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
}

# Install Pyenv and Python
install_python() {
    # Pyenv for python version management
    # Deps: https://github.com/pyenv/pyenv/wiki#suggested-build-environment
    stderr "Installing pyenv and global python version..."
    check_env "PYTHON_VERSION"

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
}

# Rust and Rust Analyzer
install_rust() {
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
}

# Zig from source
install_zig() {
    stderr "Installing Zig and its developer tools..."
    check_env "ZIG_VERSION" "ZIG_COMMIT"

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
}

# ------------------------------------------------------------------------------------
# Editor and Tools
# ------------------------------------------------------------------------------------

# Tree Sitter
install_tree_sitter() {
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
}

# Tree Sitter Bulk Grammars
# (https://git.savannah.gnu.org/cgit/emacs.git/tree/admin/notes/tree-sitter/starter-guide?h=feature/tree-sitter#n56)
# In emacs: Set treesit-extra-load-path to the dist/ directory where these dynamic libraries end up.
# Or add them to your /usr/local/lib which is where your system expects them to be.
install_tree_sitter_grammars() {
    stderr "Installing tree sitter grammars"

    if [[ -e $BIN/tree-sitter-grammars ]]; then
	stderr "Treesitter grammars already installed"
    else
	git clone https://github.com/casouri/tree-sitter-module.git $DOWNLOADS/tree-sitter-grammars
	cd $DOWNLOADS/tree-sitter-grammars
	JOBS=8 ./batch.sh
	ln -s "$DOWNLOADS/tree-sitter-grammars/dist" "$BIN/tree-sitter-grammars"
	cd $CONFIG
    fi
}

# Emacs from source <3
install_emacs() {
    stderr "Installing Emacs from Source"
    check_env "EMACS_VERSION" "EMACS_BRANCH"

    if command_exists "emacs"; then
	stderr "Emacs already installed"
    else
	mkdir $DOWNLOADS/emacs$EMACS_VERSION
	cd $DOWNLOADS/emacs$EMACS_VERSION
	git clone --depth 1 -b $EMACS_BRANCH https://git.savannah.gnu.org/git/emacs.git ./

	# Get required packages
	sudo apt-get update
	sudo apt-get install -y \
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
}

# Install neovim from source:
#    https://github.com/neovim/neovim/wiki/Building-Neovim
#    https://github.com/neovim/neovim/wiki/Installing-Neovim#install-from-source
install_neovim() {
    stderr "Installing Neovim from Source"
    check_env "NEOVIM_VERSION" "NEOVIM_BRANCH"

    if command_exists "nvim"; then
	stderr "Neovim already installed"
    else
	mkdir $DOWNLOADS/neovim$NEOVIM_VERSION
	cd $DOWNLOADS/neovim$NEOVIM_VERSION

	sudo apt-get install -y \
	     ninja-build \
	     gettext \
	     cmake \
	     unzip

	git clone https://github.com/neovim/neovim -b $NEOVIM_BRANCH ./
	make CMAKE_BUILD_TYPE=Release # RelWithDebInfo
	rm -r build/  # clear the CMake cache

	# could just build to: $BIN/neovim$NEOVIM_VERSION - w/e you like...
	make CMAKE_EXTRA_FLAGS="-DCMAKE_INSTALL_PREFIX=/usr/local/neovim/$NEOVIM_VERSION"
	sudo make install

	ln -s "/usr/local/neovim/$NEOVIM_VERSION/bin/nvim" "$BIN/nvim"
	
	cd $CONFIG
    fi
}
