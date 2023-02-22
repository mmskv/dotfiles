## Bold colors
set fish_color_command ccccc --bold
set fish_color_host brcyan
set fish_color_error e84f4f
set fish_color_quote green 
set fish_color_param 9dc4c4
set fish_color_escape 00a6b2
set fish_color_valid_path brblue
set fish_color_comment white
set fish_color_cancel red
set fish_color_redirection magenta
set fish_color_keyword bryellow --bold
set fish_color_end brmagenta --bold
set fish_color_operator brmagenta --bold
set fish_pager_color_progress brwhite --background=black
set fish_pager_color_selected_background -b black
set fish_pager_color_description 'B3A06D'  'yellow'

## Aliases
alias l "ls -lh --group-directories-first --color=always"
alias la "ls -a --color=always"
alias ll "ls -alh --color=always"
alias grep "grep --color=auto -i"
alias clone "git clone --depth 1"
alias ra "ranger"
alias wgp "wgetpaste -X"
alias sudo "doas"
alias vim "nvim"
alias reboot "sudo reboot"
alias poweroff "sudo poweroff"
alias ssh "TERM=xterm-256color /usr/bin/ssh"

alias euses "equery uses"
alias cp "cp -iv"
alias mv "mv -iv"
alias rm "rm -v"
alias ip "ip -c"

## Keybinding
set fish_key_bindings fish_vi_key_bindings

set fish_cursor_default block
set fish_cursor_insert line
set fish_cursor_replace_one underscore
set fish_cursor_visual block

## Locale
set -x LC_ALL en_US.utf8
set -x LANGUAGE en_US.utf8
set -x EDITOR /usr/bin/nvim
set -x BROWSER /usr/bin/firefox-bin
set -x MANPAGER manpager

## Start X at login
if status --is-login
  if test (tty) = /dev/tty1
    exec startx -- -maxbigreqsize 127
  end
end
