{
  desktopTheme,
  pkgs,
  ...
}: {
  home.packages =
    (with pkgs; [
      obsidian
      thunar
      thunar-volman
      pavucontrol
      playerctl
      libreoffice-qt
      hunspell
      hunspellDicts.en_US
      hunspellDicts.ru_RU
      playerctl
      pamixer
      btop
      tauon
      mpv
      dragon-drop
      telegram-desktop
      google-chrome
      element-desktop
      gimp3
      easyeffects
      gh
      darktable
    ])
    ++ desktopTheme.fonts.packages;
}
