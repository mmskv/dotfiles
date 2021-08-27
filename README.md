# My gentoo dotfiles

![](https://github.com/maksmeshkov/dotfiles/blob/laptop/screenshots/laptop-neofetch.png)

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

-   `zathura` - pdf/ebooks
-   `nvim` - text editor
    -   `coc.nvim` - extension manager for nvim
-   `Fira Mono patched for Powerline` - font for termite
-   `kochi` - japanese font
-   `arc` - icon theme
-   `qutebrowser` - web browser
-   `alacritty` - terminal
-   `ranger` - curses filemanager
-   `redshift` - ease bluelight strain on your eyes
-   `moc` - terminal music player
-   `fish` - shell
-   `maim` - screenshot
-   `doas` - sudo without bloat
-   `opendoas-sudo` - doas wrapper for sudo compatibility
-   `dmenu` - app launcher
-   `qbittorrent` - torrent client
-   `picom` - compositor
-   `dunst` - notification daemon
-   `wacom-utility` - manage wacom tablet
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

## Bugs

-   If bspwm reload is run when focused on second monitor, window number
    keybinds move to that monitor.
