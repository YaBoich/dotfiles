# ==============================================================================
# My PowerShell Startup File.
# ==============================================================================
#
# Unfortunately I cannot do things like install Chocolatey package manager here
# as you need to stuff like that from an elevated shell. So manual steps seem
# unavoidable on Windows. See the install instructions for Choco:
# - https://chocolatey.org/install
#
# Installing packages like ripgrep also need to be done from an elevated shell.
# So I've added functions here that you can just run from there.


# Emojis
$GREEN = [System.Char]::ConvertFromUtf32([System.Convert]::ToInt32("1F7E2", 16))
$RED = [System.Char]::ConvertFromUtf32([System.Convert]::ToInt32("1F534", 16))
$YELLOW = [System.Char]::ConvertFromUtf32([System.Convert]::ToInt32("1F7E1", 16))
$COOL = [System.Char]::ConvertFromUtf32([System.Convert]::ToInt32("1F60E", 16))
$DWEEB = [System.Char]::ConvertFromUtf32([System.Convert]::ToInt32("1F978", 16))
$NERD = [System.Char]::ConvertFromUtf32([System.Convert]::ToInt32("1F913", 16))

function Greeting {
    $greetings = @("What's up, Pimp!", "Morning, Dweeb!", "Evening, Thug-Danger!", "Sup Danger-Daniel!", "Aha... a-suh, Dude.")
    $emojis = @($NERD, $COOL, $DWEEB)
    $randomGreeting = Get-Random -InputObject $greetings
    $randomEmoji = Get-Random -InputObject $emojis
    Write-Output ($randomGreeting + " " + $randomEmoji)
}
Greeting

function Check-ChocoInstalled {
    if (Get-Command choco -ErrorAction SilentlyContinue) {
        Write-Output ($GREEN + "Chocolatey is installed.")
    } else {
        Write-Output ($RED + "Please install Chocolatey Package Manager in an elevated shell.")
    }
}
Check-ChocoInstalled

function Install-Packages {
    choco install ripgrep
}
function Check-Installed-Packages {
    if (!(Get-Command choco -ErrorAction SilentlyContinue)) {
	return
    }
    if (!(Get-Command rg -ErrorAction SilentlyContinue)) {
	Write-Output ($RED + "RipGrep is not installed")
	Write-Output "-> Please run `Install-Packages` command in an elevated shell."
	return
    }
    Write-Output ($GREEN + "Packages are installed")
}
Check-Installed-Packages

# ------------------------------------------------------------------------------
# Git
# ------------------------------------------------------------------------------
function gs { git status }

# ------------------------------------------------------------------------------
# Directories
# ------------------------------------------------------------------------------
$DIR_REPOS = "C:\r\"
$DIR_DOTFILES = "~/.dotfiles/"

function dirRepos { cd $DIR_REPOS }
function dirDotfiles { cd $DIR_DOTFILES }

# ------------------------------------------------------------------------------
# Improve PowerShell Experience
# ------------------------------------------------------------------------------

function Ensure-PSReadline {
    # https://github.com/PowerShell/PSReadLine
    # PSReadLine provides functionality similar to OhMyZsh:
    # - syntax coloring
    # - syntax prediction
    # - good multi-line editing experience

    $module = Get-Module -ListAvailable -Name PSReadLine
    if ($null -eq $module) {
        Write-Output ($YELLOW + "PSReadLine is not installed. Installing now...")
        Install-Module -Name PSReadLine -Scope CurrentUser -Force -AllowClobber
    } else {
        Write-Output ($GREEN + "PSReadLine is installed.")
    }
    # Import the module
    Import-Module PSReadLine

    # Configure (check options with Get-PSReadLineOption)
    Set-PSReadLineOption -EditMode Windows
    Set-PSReadLineOption -CompletionQueryItems 5

    # This changes most commands to unix-style, such as TAB
    Set-PSReadLineOption -EditMode Emacs
}
Ensure-PSReadline
