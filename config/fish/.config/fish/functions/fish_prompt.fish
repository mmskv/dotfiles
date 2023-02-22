function fish_prompt
    if test -z "$WINDOW"
        if test -e /.dockerenv
            printf '%s%s%s%s%s ' \( (set_color -o brred) docker (set_color normal) \)
        end

        printf '%s%s%s%s%s%s %s%s%s' (set_color -o $fish_color_user) $USER (set_color bryellow) (echo -n "@") (set_color $fish_color_host) (prompt_hostname) (set_color blue) (prompt_pwd) 

        if git rev-parse --is-inside-work-tree > /dev/null 2>&1
            printf '%s%s%s' (set_color normal) (set_color green) (fish_git_prompt)
        end
 
        printf '%s%s%s ' (set_color -o brwhite) (echo -n ">") (set_color normal)
    else
        printf '%s%s@%s%s%s(%s)%s%s%s> ' (set_color $fish_color_user) $USER (set_color $fish_color_host) (prompt_hostname) (set_color white) (echo $WINDOW) (set_color cyan) (prompt_pwd) (set_color normal)
    end
end
