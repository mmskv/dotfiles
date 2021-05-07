# My gentoo dotfiles

![](https://github.com/maksmeshkov/dotfiles/blob/dracula/screenshots/gray-stable-neofetch.png)
![](https://github.com/maksmeshkov/dotfiles/blob/dracula/screenshots/gray-stable-workflow.png)

---

## Install

1.  Backup your .config folder

        tar -chzf ~/.config/ dotconfig.bkp

2.  Install dotfiles

        cd config
        stow * -t ~/ # You can specify what to install

## Apps list

-   `zathura` - pdf/ebooks
-   `nvim` - text editor
    -   `coc.nvim` - extension manager for nvim
-   `Fira Mono patched for Powerline` - font for termite
-   `kochi` - japanese font
-   `arc` - icon theme
-   `vivaldi` - web browser
-   `urxvt` - terminal
-   `ranger` - curses filemanager
-   `redshift` - ease bluelight strain on your eyes
-   `moc` - terminal music player
-   `fish` - shell
-   `maim` - screenshot
-   `doas` - sudo without bloat
-   `wacom-utility` - manage wacom tablet
-   `dmenu` - app launcher
-   `qbittorrent` - torrent client
-   `picom` - compositor
-   `dunst` - notification daemon (I don't use notifications a lot)
-   [`gentoo-lto`](https://github.com/InBetweenNames/gentooLTO) - use to optimize compiled programs

---

-   `yay` - aur packet manager
-   `arandr` - GUI for xrandr
-   `lxappearance` - set gkt theme
-   `linux zen` - kernel (don't forget to install dkms hooks for nvidia)
-   `thunar` - GUI file manager
-   `pywal` - colorscheme setter
-   `nerd` fonts complete - every font in one place

## Notes

-   To use dbus for spotify, chromium, playerctl and whatever, launch WM
    session with dbus, so that all WM children will be children of dbus. Put
    `exec dbus-launch --exit-with-session bspwm` in your `.xinitrc`
-   Install all coc extensions in one line

        :CocInstall coc-snippets coc-prettier coc-git coc-eslint coc-vimtex coc-tsserver coc-sh coc-pyright coc-json coc-css coc-cmake coc-clangd

## Bugs

-   If bspwm reload is run when focused on second monitor, window number
    keybinds move to that monitor.
