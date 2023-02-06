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
alias wgp "wgetpaste -X"
alias sudo "doas"

alias euses "equery uses"
alias cp "cp -iv"
alias mv "mv -iv"
alias rm "rm -v"
alias ip "ip -c"

## Keybinding
set fish_key_bindings fish_vi_key_bindings

## Locale
set -x LC_ALL en_US.utf8
set -x LANGUAGE en_US.utf8
set -x EDITOR /usr/bin/nvim
set -x BROWSER /usr/bin/firefox-bin

## Start X at login
if status --is-login
  if test (tty) = /dev/tty1
    exec startx -- -maxbigreqsize 127
  end
end
