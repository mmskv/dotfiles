function fish_prompt --description 'Screen Savvy prompt'
    if test -z "$WINDOW"
        printf '%s%s@%s%s%s %s%s> ' (set_color -o yellow) $USER (set_color purple) (prompt_hostname) (set_color $fish_color_cwd) (prompt_pwd) (set_color normal)
    else
        printf '%s%s@%s%s%s(%s)%s%s%s> ' (set_color yellow) $USER (set_color purple) (prompt_hostname) (set_color white) (echo $WINDOW) (set_color $fish_color_cwd) (prompt_pwd) (set_color normal)
    end
end

## Aliases
alias l "ls -lh --group-directories-first --color=always"
alias la "ls -a --color=always"
alias ll "ls -alh --color=always"
alias grep "grep --color=auto -i"
alias clone "git clone --depth 1"
alias ra "ranger"

alias euses "equery uses"
alias cp "cp -iv"
alias mv "mv -iv"
alias rm "rm -v"

alias librespot "/home/overaid/github/librespot/target/release/librespot -n Ono-Sendai"
alias 'commit'='set -x GPG_TTY (tty); git commit -S'
alias gitlog "git log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)' --all"

## Keybinding
set fish_key_bindings fish_vi_key_bindings

## Locale
set -x LC_ALL en_US.utf8
set -x EDITOR /usr/bin/nvim
