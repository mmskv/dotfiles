# My arch macbook air dotfiles

![](https://github.com/maksmeshkov/dotfiles/blob/laptop/screenshots/screenshot.png)

---

## Install

1.  Backup your .config folder

        tar -chzf ~/.config/ dotconfig.bkp

2.  Install dotfiles

        cd config
        stow * -t ~/ # You can specify what to install

### Patches

-   Patch to use ctrl + space to switch kb layout.
    `setxkbmap -option grp:alt_space_toggle` should be used then

         patch /usr/share/X11/xkb/symbols/group patches/control_space_xkb_layout.patch

## Apps list

-   `river` - wayland compositor
-   `zathura` - pdf/ebooks
-   `nvim` - text editor
    -   `coc.nvim` - extension manager for nvim
-   `Fira Mono patched for Powerline` - terminal font
-   `firefox` - web browser
-   `alacritty` - terminal
-   `fish` - shell
-   `doas` - sudo without bloat
-   `opendoas-sudo` - doas wrapper for sudo compatibility
-   `dmenu-wayland-git` - launcher
-   `dunst` - notification daemon
-   `wacom-utility` - manage wacom tablet
-   `yay` - aur packet manager

## Notes

-   Install all coc extensions in one line

        :CocInstall coc-snippets coc-prettier coc-git coc-eslint coc-vimtex coc-tsserver coc-sh coc-pyright coc-json coc-css coc-cmake coc-clangd
