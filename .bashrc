# Use this file to configure interactive shells. It is called by
# bash_profile and upon launching any terminal emulator.

# If not running interactively, don't read this file
[[ $- != *i* ]] && return

# If tmux started already, attach to the session; otherwise, start it
#if [ "$TERM" != "linux" ]; then
#	[[ -z "$TMUX" ]] && exec tmux
#fi

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

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# Enable color support
export CLICOLOR='yes'
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
complete -cf sudo

# Set shell prompt
#if [ "$color_prompt" = yes ]; then
#    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
#else
#    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
#fi
#export PS1='┌──\u@\h[\w]\n└╼ '
#export PS1=' +  '

# Set color scheme
BASE16_SCHEME="eighties"
BASE16_SHADE="dark"
BASE16_SHELL="/mnt/data/builds/base16-shell/base16-${BASE16_SCHEME}.${BASE16_SHADE}.sh"
[[ -s "$BASE16_SHELL" ]] && . "$BASE16_SHELL"

# Set aliases and functions
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# Android development
export ANDROID_SDK_ROOT=~/android-sdk
PATH=$PATH:~/android-ndk
PATH=$PATH:~/android-sdk/platform-tools
PATH=$PATH:~/android-sdk/tools
PATH=$PATH:/usr/local/share/gradle/gradle-2.9/bin
export PATH
