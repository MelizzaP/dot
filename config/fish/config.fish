if status is-interactive
    # Commands to run in interactive sessions can go here
end


# Setting PATH for Python 3.12
set -x PATH "/Library/Frameworks/Python.framework/Versions/3.12/bin" "$PATH"
source $HOME/.localrc
source $HOME/.config/fish/functions/functions.fish
set -gx LUA_PATH $PATH $HOME/.config/nvim/lua
starship init fish | source

# ASDF configuration code
if test -z $ASDF_DATA_DIR
    set _asdf_shims "$HOME/.asdf/shims"
else
    set _asdf_shims "$ASDF_DATA_DIR/shims"
end

# Do not use fish_add_path (added in Fish 3.2) because it
# potentially changes the order of items in PATH
if not contains $_asdf_shims $PATH
    set -gx --prepend PATH $_asdf_shims
end

set --erase _asdf_shims
