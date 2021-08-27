# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=10000
# Case insensitive completion
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
setopt autocd extendedglob nomatch notify promptsubst
bindkey -v
# End of lines configured by zsh-newuser-install

### Added by Zinit's installer
if [[ ! -f $HOME/.zinit/bin/zinit.zsh ]]; then
    print -P "%F{33}▓▒░ %F{220}Installing %F{33}DHARMA%F{220} Initiative Plugin Manager (%F{33}zdharma/zinit%F{220})…%f"
    command mkdir -p "$HOME/.zinit" && command chmod g-rwX "$HOME/.zinit"
    command git clone https://github.com/zdharma/zinit "$HOME/.zinit/bin" && \
        print -P "%F{33}▓▒░ %F{34}Installation successful.%f%b" || \
        print -P "%F{160}▓▒░ The clone has failed.%f%b"
fi

source "$HOME/.zinit/bin/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# Load a few important annexes, without Turbo
# (this is currently required for annexes)
zinit light-mode for \
    zinit-zsh/z-a-rust \
    zinit-zsh/z-a-as-monitor \
    zinit-zsh/z-a-patch-dl \
    zinit-zsh/z-a-bin-gem-node

### End of Zinit's installer chunk

### Zinit Plugins ###
zinit wait lucid light-mode for \
    atinit"zicompinit; zicdreplay" \
        zdharma/fast-syntax-highlighting \
    atload"_zsh_autosuggest_start" \
        zsh-users/zsh-autosuggestions \
    blockf atpull'zinit creinstall -q .' \
        zsh-users/zsh-completions \
### End Zinit Plugins ###

### User Zinit Config ###

# Direnv
zinit as"program" make'!' atclone'./direnv hook zsh > zhook.zsh' \
  atpull'%atclone' pick"direnv" src"zhook.zsh" for \
    direnv/direnv
# End Direnv

# Starship
zinit ice as"command" from"gh-r" \
    atclone"./starship init zsh > init.zsh; ./starship completions zsh > _starship" \
    atpull"%atclone" src="init.zsh" 
zinit light starship/starship
# End Starship

### End User Zinit Config ###

### Aliases ###

alias ls="exa --long --icons --git"
alias cat="bat"
alias tmux="tmux -u"
alias sudo="sudo"

# Copy terminfo over on first ssh
alias ssh="kitty +kitten ssh"

alias fzf="fzf --preview '([[ -f {} ]] && (bat --style=numbers --color=always {} || cat {})) || ([[ -d {} ]] && (tree -C {} | less)) || echo {} 2> /dev/null | head -200'"

alias testenv="docker run --rm -it --cpus 1 --memory 100m ubuntu bash"

### End Aliases ###

# The following lines were added by compinstall
#zstyle ':completion:*' completer _complete _ignored _approximate
#zstyle ':completion:*' list-colors ''
#zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
#zstyle :compinstall filename '/home/viargentum/.zshrc'

#autoload -Uz compinit
#compinit
#End of lines added by compinstall

chpwd() {
  exa --long --icons --git
}

eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

source ~/.autojump/etc/profile.d/autojump.sh
source ~/.fzf.zsh
source ~/.sdkman/bin/sdkman-init.sh
