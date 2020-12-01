cat ~/.cache/wal/sequences &
fish_vi_key_bindings &

# Start X at login
if status --is-login
  if test -z "$DISPLAY" -a $XDG_VTNR = 1
    exec startx
  end
end
