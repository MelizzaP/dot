if status is-interactive
    # Commands to run in interactive sessions can go here
end


# Setting PATH for Python 3.12
set -x PATH "/Library/Frameworks/Python.framework/Versions/3.12/bin" "$PATH"
source $HOME/.localrc
source $HOME/.config/fish/functions.fish
set -gx LUA_PATH $PATH $HOME/.config/nvim/lua
starship init fish | source
