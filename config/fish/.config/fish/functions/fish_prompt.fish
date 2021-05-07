function fish_prompt --description 'Screen Savvy prompt'
    if test -z "$WINDOW"
        printf '%s%s@%s%s%s %s%s> ' (set_color -o yellow) $USER (set_color purple) (prompt_hostname) (set_color $fish_color_cwd) (prompt_pwd) (set_color normal)
    else
        printf '%s%s@%s%s%s(%s)%s%s%s> ' (set_color yellow) $USER (set_color purple) (prompt_hostname) (set_color white) (echo $WINDOW) (set_color $fish_color_cwd) (prompt_pwd) (set_color normal)
    end
end

## Right Prompt
function fish_right_prompt
    set_color white
    echo -n (date +"%H:%M")
    set_color normal
end

## Aliases
alias l "ls -lh --group-directories-first --color=always"
alias la "ls -a --color=always"
alias ll "ls -alh --color=always"
alias grep "grep --color=auto -i"
alias clone "git clone --depth 1"
alias ra "ranger"

## Keybinding
set fish_key_bindings fish_vi_key_bindings

## Locale
set -x LC_ALL en_US.utf8
set -x EDITOR /usr/bin/vim
set -x PAGER /usr/bin/vimpager
