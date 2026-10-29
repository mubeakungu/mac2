# mac2 default zsh configuration
setopt autocd interactivecomments magicequalsubst nonomatch notify numericglobsort promptsubst
HISTFILE=~/.zsh_history HISTSIZE=10000 SAVEHIST=20000
setopt hist_ignore_dups hist_ignore_space share_history
bindkey -e
autoload -Uz compinit && compinit -d ~/.cache/zcompdump
zstyle ':completion:*' menu select

# Two-line prompt in the style of Kali:  ┌──(user㉿host)-[~/dir]
#                                         └─$
PROMPT=$'%F{%(#.blue.green)}┌──(%B%F{%(#.red.cyan)}%n㉿%m%b%F{%(#.blue.green)})-[%B%F{reset}%(6~.%-1~/…/%4~.%5~)%b%F{%(#.blue.green)}]\n└─%B%(#.%F{red}#.%F{cyan}$)%b%F{reset} '

alias ls='ls --color=auto' ll='ls -lh' la='ls -A' grep='grep --color=auto' ip='ip --color=auto'

[ -f /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ] && . /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
[ -f /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ] && . /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
