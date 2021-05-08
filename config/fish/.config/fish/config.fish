#cat ~/.cache/wal/sequences > /dev/null &
fish_vi_key_bindings &

set --unexport COLUMNS
set --unexport LINES

set fish_color_command ccccc --bold
set fish_color_error e84f4f
set fish_color_quote b7ce42 
set fish_color_cwd fea63c --bold
set fish_color_param 66a9b9

# Start X at login
if status --is-login
  if test -z "$DISPLAY" -a $XDG_VTNR = 1
    exec startx
  end
end
