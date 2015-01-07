#!/usr/bin/fish

# Remove welcome message
set fish_greeting ""

# Set keybindings
function fish_user_key_bindings
    bind \el 'accept-autosuggestion'
    bind \ek 'history-search-backward'
    bind \ej 'history-search-forward'
end

# Fix color output
eval (dircolors -c ~/.dircolors | sed 's/>&\/dev\/null$//')

# Load aliases
. ~/.config/fish/aliases.fish
