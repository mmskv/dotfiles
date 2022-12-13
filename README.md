# My gentoo dotfiles

![](https://github.com/maksmeshkov/dotfiles/blob/desktop/screenshots/desktop.png)

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

         sudo patch /usr/share/X11/xkb/symbols/group patches/control_space_xkb_layout.patch

## Apps list

-   `zathura` - pdf/ebooks
-   `neovim` - text editor
-   `Fira Mono for Powerline` - font
-   `kochi` - japanese font
-   `firefox` - web browser
-   `tridactyl` - vim bindings for firefox
-   `alacritty` - terminal
-   `redshift` - ease bluelight strain on your eyes
-   `ncmpcpp` - terminal music player
-   `fish` - shell
-   `maim` - screenshot
-   `doas` - sudo without bloat
-   `dmenu` - app launcher
-   `picom` - compositor
-   `dunst` - notification daemon
-   `wacom-utility` - manage wacom tablet
-   `nomacs` - image viewer
-   [`gentoo-lto`](https://github.com/InBetweenNames/gentooLTO) - use to optimize compiled programs

---

-   `yay` - aur packet manager
-   `arandr` - GUI for xrandr
-   `lxappearance` - set gkt theme
-   `thunar` - GUI file manager
-   `nerd fonts complete` - every font in one place

## Notes

-   Install all coc extensions in one line

        :CocInstall coc-snippets coc-prettier coc-git coc-eslint coc-vimtex coc-tsserver coc-sh coc-pyright coc-json coc-css coc-cmake coc-clangd
