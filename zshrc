# Put anything that outputs up here, above the p10k instant prompt to avoid a big warning message that it prints

# because I always forget to tear down my docker compose environments
print_docker_uptime() {
  if ! command -v docker > /dev/null
  then
    return
  fi

  local now=$(date +%s)
  local yellow='\033[1;33m'
  local reset='\033[0m'

  docker ps --format '{{.ID}} {{.Names}} {{.RunningFor}}' | while read -r id name running_for; do
    start_time=$(docker inspect -f '{{.State.StartedAt}}' "$id")
    start_timestamp=$(date -d "$start_time" +%s)
    uptime_seconds=$(( now - start_timestamp ))

    if (( uptime_seconds > 28800 )); then
      echo -e "${yellow}Docker container '$name' (ID: $id) has been up for more than 8 hours${reset}"
    fi
  done
}
print_docker_uptime

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="powerlevel10k/powerlevel10k"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
  git
  colored-man-pages
  zsh-autosuggestions
  zsh-completions
  zsh-syntax-highlighting
  docker
)

# eksctl completions and others. must go before compinit!
fpath=($fpath ~/.zsh/completion)

ulimit -c unlimited

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
alias k="kubectl"
command -v kubectl > /dev/null && source <(kubectl completion zsh)

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

if [ -d "$HOME/.local/bin" ] ; then
    export PATH="$HOME/.local/bin:$PATH"
fi

export PATH=$PATH:$HOME/bin/:$HOME/liquibase/:$HOME/go/bin/
[[ -f "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"

export AVR_BIN_DIR=$HOME/avr8-gnu-toolchain-linux_x86_64/bin/

[[ -f /home/linuxbrew/.linuxbrew/bin/brew ]] && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

complete -C aws_completer aws

aws_docker_login() {
  local ACCOUNT_ID="$1"
  local REGION="${2:-us-east-2}"
  if [[ -z "$ACCOUNT_ID" ]]; then
    echo "Usage: aws_docker_login <account ID> <region (optional)>"
    return
  fi
  aws --profile "AWSAdministratorAccess-$ACCOUNT_ID" ecr get-login-password --region "$REGION" | docker login --username AWS --password-stdin "$ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com"
}

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$("$HOME/miniconda3/bin/conda" 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "$HOME/miniconda3/etc/profile.d/conda.sh" ]; then
        . "$HOME/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="$HOME/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

command -v eksctl >/dev/null && . <(eksctl completion zsh)

export PATH=$PATH:/usr/local/cuda-12.1/bin/
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/cuda-12.1/lib64/

[[ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]] && source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
export NIXPKGS_ALLOW_UNFREE=1

command -v direnv >/dev/null && eval "$(direnv hook zsh)"

export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

# all git stuff
alias grbc="git rebase --continue"
alias gmm="git merge $(git_main_branch)"
alias gmc="git merge --continue"
alias gfa="git fetch --all --prune --tags --jobs=10"

alias gbl="git blame -w -C -C -C" # ignore whitespace and be smart about moved lines in any commit. slow but helpful
gfom() {
	git fetch origin "$(git_main_branch):$(git_main_branch)"
}
gfum() {
	git fetch upstream "$(git_main_branch):$(git_main_branch)"
}
gpum() {
	git pull upstream "$(git_main_branch):$(git_main_branch)"
}
gmb() {
	git merge-base HEAD "$(git_main_branch)"
}

# git diff
alias gd="git diff"
alias gdc="git diff --cached"
alias gdh="git diff HEAD\^..HEAD"
alias gdim="git diff-image"
alias gdsm="git diff --submodule=diff"
gdm() {
	git diff "$(git_main_branch)"..HEAD
}
gdcm() {
	git diff "$1^..$1"
}

# git commit
alias gcan="git commit -v -a --no-edit --amend"
gfu() {
	git commit --fixup "$1"
}
gfua() {
	git commit -a --fixup "$1"
}
gfuh() {
	git commit -a --fixup HEAD
}

# github cli
alias gpw="gh pr view --web"
alias grw="gh repo view -w"
alias gpc="gh pr create --assignee Octogonapus"
alias gpm="gh pr merge --squash --delete-branch"
gprl() {
	echo "$(gh pr view --json url --jq .url)"
}

git_squash_branch() {
    if [ `git status --porcelain=1 | wc -l` -ne 0 ]; then
        echo "error: i won't squash if you have uncommitted changes!"
        return 1
    fi
    rev=$(git rev-parse HEAD)
    git reset $(git merge-base main $(git branch --show-current))
    echo "You were at: $rev"
}

unalias gb
gb() {
	if [ $# -eq 0 ]; then
		for k in $(git branch | sed 's/^..//')
		do
			echo -e $(git log --color=always -1 --pretty=format:"%Cgreen%ci %Cblue%cr%Creset" $k --)\\t"$k"
		done | sort
	else
		git branch "$@"
	fi
}
compdef _git gb=git-branch

gmo() {
	git merge "origin/$1"
}
compdef _git gmo=git-merge

export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
command -v pyenv >/dev/null && eval "$(pyenv init -)"

export PATH="$HOME/go/bin:$PATH"

[[ -f /opt/intel/oneapi/vtune/latest/env/vars.sh ]] && source /opt/intel/oneapi/vtune/latest/env/vars.sh

export PATH="$HOME/bin:$PATH"

alias dc="docker compose"
alias dcd="docker compose down"
alias dcl="docker compose logs -f -n 10"

kill_all_docker_containers() {
    ids=($(docker ps -q))
    for id in $ids; do
        docker kill "$id"
    done
}

# >>> juliaup initialize >>>

# !! Contents within this block are managed by juliaup !!

path=("$HOME/.juliaup/bin" $path)
export PATH

# <<< juliaup initialize <<<

julia_manifest() {
	local dir=$(pwd)
	while [[ "$dir" != '/' ]]; do
		if [[ -f "$dir/Manifest.toml" ]]; then
			JULIA_VER=$(grep julia_version "$dir/Manifest.toml" | cut -d'=' -f2 | xargs)
			echo "using: $dir/Manifest.toml"
			break
		fi
		dir=$(dirname "$dir")
	done
	julia +"$JULIA_VER" "$@"
}

ls_core_dumps() {
	local ROOT="/mnt/c/Users/salmon/AppData/Local/Temp/wsl-crashes/"
	find "$ROOT" -type f -printf '%s %t %p\n'
}

bump_pr() {
    local pr="$1"
    
    if [[ -z "$pr" ]]; then
        echo "Usage: nump_pr <github-pr-url>"
        return 1
    fi
    
    local repo=$(echo "$pr" | sed -E 's|(https://github.com/([^/]+/[^/]+))/pull/([0-9]+).*|\1.git|')
    local pr_number=$(echo "$pr" | sed -E 's|.*/pull/([0-9]+).*|\1|')
    local dir=$(mktemp -d)
    
    gh repo clone "$pr" "$dir" || return 1
    cd "$dir" || return 1
    
    gh pr checkout "$pr" || return 1
    
    git commit --allow-empty -m "chore: empty commit to trigger build" || return 1
    git push origin || return 1
    
    cd - || return 1
    rm -rf "$dir" || return 1
}

# pnpm
export PNPM_HOME="$HOME/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"

utc() {
  echo "UTC:   $(date -u -d "@$1")"
  echo "Local: $(date -d "@$1")"
}

sutc() {
  echo "UTC:   $(date -u -d "@$1" +"%F %T")"
  echo "Local: $(date -d "@$1" +"%F %T")"
}

alias p="pnpm"
alias px="pnpx"
alias pxu="pnpx npm-check -u"
alias pb="pnpm run build"
alias pd="pnpm run dev"
alias pt="pnpm run tauri"
alias pi="pnpm install"

alias tssh="tailscale ssh"
alias tst="tailscale status"
alias tping="tailscale ping"

export RUST_BACKTRACE=1
export SSH_AUTH_SOCK=$HOME/.1password/agent.sock
export BROWSER="/mnt/c/Program Files/Google/Chrome/Application/chrome.exe"

export ASDF_DATA_DIR="$HOME/.asdf"
export PATH="$ASDF_DATA_DIR/shims:$PATH"
fpath=(${ASDF_DATA_DIR:-$HOME/.asdf}/completions $fpath) # before compinit
# asdf scripts must be sourced after setting PATH and after sourcing oh-my-zsh.sh
[[ -f "${ASDF_DATA_DIR}/plugins/golang/set-env.zsh" ]] && source "${ASDF_DATA_DIR}/plugins/golang/set-env.zsh"

unshare_net() {
	local dir cmd_string
	dir=$(pwd)
	cmd_string=$(printf '%q ' "$@")
	sudo unshare --net --fork su - "$USER" -c "cd $(printf '%q' "$dir") && $cmd_string"
}

autoload -Uz compinit && compinit

export ANSIBLE_NOCOWS=1

# platform-specific
[[ -f "$HOME/.zshrc_wsl" ]] && source "$HOME/.zshrc_wsl"

# zshrc_local must come last
if [[ -f "$HOME/.zshrc_local" ]]; then
  source "$HOME/.zshrc_local"
else
  echo "$HOME/.zshrc_local does not exist! You probably forgot to install it manually."
fi

[[ -f "$HOME/.safe-chain/scripts/init-posix.sh" ]] && source "$HOME/.safe-chain/scripts/init-posix.sh"
