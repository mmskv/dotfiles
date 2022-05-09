# Pacman hooks

Put them into `/usr/share/libalpm/hooks/`

## patch-mkinitcpio-encrypt-hook

Adds timeout to luks password prompt

    sudo cp encrypt.patch /usr/share/libalpm/
    sudo chmod 644 /usr/share/libalpm/encrypt.patch
    sudo cp patch-mkinitcpio-encrypt-hook.hook /usr/share/libalpm/hooks
    sudo chmod 644 /usr/share/libalpm/hooks/patch-mkinitcpio-encrypt-hook.hook
