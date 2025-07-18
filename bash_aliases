# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# git aliases
alias grbm='git rebase main'
alias grbc='git rebase --continue'
alias gmc="git merge --continue"
alias gll='git log --graph --pretty=oneline --abbrev-commit'

alias python='python3'

extract() {
    if [ -f "$1" ]; then
        case $1 in
        *.tar.bz2) tar xvjf "$1" ;;
        *.tar.gz) tar xvzf "$1" ;;
        *.bz2) bunzip2 "$1" ;;
        *.rar) unrar x "$1" ;;
        *.gz) gunzip "$1" ;;
        *.tar) tar xvf "$1" ;;
        *.tbz2) tar xvjf "$1" ;;
        *.tgz) tar xvzf "$1" ;;
        *.zip) unzip "$1" ;;
        *.Z) uncompress "$1" ;;
        *.7z) 7z x "$1" ;;
        *) echo "don't know how to extract '$1'..." ;;
        esac
    else
        echo "'$1' is not a valid file!"
    fi
}

# platform-specific
[[ -f "$HOME/.bash_aliases_wsl" ]] && source "$HOME/.bash_aliases_wsl"
