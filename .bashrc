# Use this file to configure interactive shells. It is called by
# bash_profile and upon launching any terminal emulator.

# If not running interactively, don't read this file
[[ $- != *i* ]] && return

# If tmux started already, attach to the session; otherwise, start it
#[[ -z "$TMUX" ]] && exec tmux

# Source environment variables
[[ -f ~/.profile ]] && source ~/.profile

# Don't put duplicate lines or lines starting with space in the history
HISTCONTROL=ignoreboth

# Append to the history file (don't overwrite it)
shopt -s histappend

# Set history length
HISTSIZE=1000
HISTFILESIZE=2000

# Automatically update LINES and COLUMNS on window resize
shopt -s checkwinsize

# Enable color support
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
fi

# Enable completion
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# Set shell prompt
if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
#export PS1='┌──\u@\h[\w]\n└╼ '
#export PS1=' +  '

# Set color scheme
BASE16_SCHEME="default"
BASE16_SHADE=""
BASE16_SHELL="~/.builds/base16-shell/base16-$BASE16_SCHEME.$BASE16_SHADE.sh"
[[ -s $BASE16_SHELL ]] && . $BASE16_SHELL

# Set aliases and functions
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# Set vi input mode
#set -o vi

# Autostart
#if [ "$TERM" != "linux" ]; then
#    archey3
#fi

# Android Studio
PATH=$PATH:/opt/android-studio/bin
export PATH
