#####################################################################################
#                               ZSH Basic Config                                    #
#####################################################################################

export PATH=$HOME/bin:/usr/local/bin:$PATH # Ensure PATH consistency
export ZSH="$HOME/.oh-my-zsh" # Oh-My-Zsh path

# Themes: https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="random"
ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" )

ENABLE_CORRECTION="true" # Enable command auto-correction
COMPLETION_WAITING_DOTS="true" # Waiting dots during completion
                               # WARN: Can cause issues with multi-line prompts

# Troubleshooting (Uncomment as required):
# DISABLE_MAGIC_FUNCTIONS="true"  # Helps if pasting URLs/text is misbehaving
# DISABLE_UNTRACKED_FILES_DIRTY="true"  # Speeds up status check for large repos
# HIST_STAMPS="mm/dd/yyyy"  # Changes the history command timestamp format

# Plugins -> Standard: $ZSH/plugins/ || Custom: $ZSH_CUSTOM/plugins/
plugins=(git)

source $ZSH/oh-my-zsh.sh

#####################################################################################
#                                MY CONFIG                                          #
#####################################################################################

#---------------------------- VIM Bindings & Modes ----------------------------------
bindkey -v  # Enable vi keybindings in terminal

# Cursor mode indications
function zle-line-init zle-keymap-select {
    case $KEYMAP in 
    	vicmd) print -n "\e[1 q";;       # Block cursor for NORMAL mode
    	main|viins) print -n "\e[5 q";;  # Line cursor for INSERT mode
    esac
    zle reset-prompt
}
zle -N zle-line-init
zle -N zle-keymap-select

# Mode prompt indicator
function vi_mode_prompt_info() {
    echo "${${KEYMAP/vicmd/[N]}/(main|viins)/   } "
}
PROMPT='$(vi_mode_prompt_info)'$PROMPT

#--------------------------------- Neovim -------------------------------------------
# nvim by default, alias should protect us if nvim doesn't exist
# Otherwise - good luck using nano, lol.
export PATH="$HOME/neovim/bin:$PATH"
if command -v nvim > /dev/null 2>&1; then
    alias vim='nvim' 
fi

#---------------------------- General / Misc ----------------------------------------
# Setup history
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
setopt hist_ignore_dups        # Prevent duplicate history entries
setopt share_history           # Share command history across all sessions

setopt no_beep                 # Disable tab beeping
export EDITOR='vim'            # Set the default editor

# Extended file globbing (helps with advanced pattern matching)
setopt EXTENDED_GLOB     

#-------------------------- Package & Language Config -------------------------------
# NVM and completion setup
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

#------------------------------- Aliases --------------------------------------------
alias gs="git status"
alias gpl="git push"
alias gph="git pull"
alias ga="git add"
alias gc="git commit -m"
alias gco="git checkout"
alias gb="git branch"
alias gba="git branch -a"
alias gl="git log"
alias gd="git diff"
alias gm="git merge"
alias grb="git rebase"
alias gdm="git diff origin master"

alias editConfig="vim ~/.zshrc"
alias sourceConfig="source ~/.zshrc"

alias dirHome="cd ~/"
alias dirWork="cd ~/Work"

alias ll="ls -la"                      # Detailed list view
alias ..="cd .."                       # Quickly move up one directory
alias ...="cd ../.."                   # Quickly move up two directories

# maven
alias mvnc="mvn clean"                 
alias mvnp="mvn package"
alias mvni="mvn install"

# nvm
alias nis="npm install --save"
alias nid="npm install --save-dev"
alias nst="npm start"
alias nt="npm test"

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

#---------------------------- Python stuff ------------------------------------------

alias pipup="pip install --upgrade pip"                # Upgrade pip itself
alias pipout="pip list --outdated"                     # List outdated packages
                                                       # Upgrade all packages
alias pipupall="pip list --outdated --format=freeze | grep -v '^\-e' | cut -d = -f 1 | xargs -n1 pip install -U"  
alias piplist="pip list"                               # List installed packages
pipsea() { pip search "$1"; }                          # Search on PyPI
alias pipin="pip install -r requirements.txt"          # Install from requirements.txt
alias pipfreeze="pip freeze > requirements.txt"        # Generate requirements.txt
pipun() { pip uninstall "$1"; }                        # Uninstall a package
pipshow() { pip show "$1"; }                           # Show package details
pipeditable() { pip install -e "$1"; }                 # Install package in editable mode

pipmkenv() { python -m venv "$1"; }                    # Create new virtual environment
alias pipact="source venv/bin/activate"                # Activate virtual environment
alias pipdeact="deactivate"                            # Deactivate virtual environment
piprmenv() {                                           # Remove virtual environment
    [ -d "venv" ] && rm -r venv || echo "No 'venv' directory found.";
}

