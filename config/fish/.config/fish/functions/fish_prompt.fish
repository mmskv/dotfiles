function fish_prompt --description 'Screen Savvy prompt'
    if test -z "$WINDOW"
        if git rev-parse --is-inside-work-tree > /dev/null 2>&1
            printf '%s%s%s%s%s%s %s%s%s%s' (set_color -o F0C674) $USER (set_color B294BB) (echo -n "@") (set_color 81A2BE) (prompt_hostname) (set_color $fish_color_cwd) (prompt_pwd) (set_color normal) (set_color B5BD68) (fish_git_prompt) (set_color -o B5BD68) (echo ">") (set_color normal)
        else
            printf '%s%s%s%s%s%s %s%s%s%s' (set_color -o F0C674) $USER (set_color B294BB) (echo -n "@") (set_color 81A2BE) (prompt_hostname) (set_color $fish_color_cwd) (prompt_pwd) (set_color -o 8ABEB7) (echo -n ">") (set_color normal)
        end
    else
        printf '%s%s@%s%s%s(%s)%s%s%s> ' (set_color yellow) $USER (set_color purple) (prompt_hostname) (set_color white) (echo $WINDOW) (set_color $fish_color_cwd) (prompt_pwd) (set_color normal)
    end
end
