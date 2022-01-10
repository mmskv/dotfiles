## Fix for curses applications where terminal would not update 
## $COLUMNS and $LINES
set --unexport COLUMNS
set --unexport LINES

## Bold colors
set fish_color_command ccccc --bold
set fish_color_error e84f4f
set fish_color_quote b7ce42 
set fish_color_cwd fea63c --bold
set fish_color_param 66a9b9

## Aliases
alias l "ls -lh --group-directories-first --color=always"
alias la "ls -a --color=always"
alias ll "ls -alh --color=always"
alias grep "grep --color=auto -i"
alias clone "git clone --depth 1"
alias ra "ranger"

alias cp "cp -iv"
alias mv "mv -iv"
alias rm "rm -v"

## Keybinding
set fish_key_bindings fish_vi_key_bindings

## Locale
set -x LC_ALL en_US.utf8
set -x EDITOR /usr/bin/nvim
set -x BROWSER /usr/bin/qutebrowser
set -x SSH_AUTH_SOCK "$XDG_RUNTIME_DIR/ssh-agent.socket"

## XKB
set -x XKB_DEFAULT_OPTIONS caps:escape,grp:alt_space_toggle
set -x XKB_DEFAULT_LAYOUT us,ru

## Start X at login
if status --is-login
  if test -z "$DISPLAY" -a $XDG_VTNR = 1
    exec river
  end
end
