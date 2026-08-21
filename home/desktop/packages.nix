{
  pkgs,
  pkgs-unstable,
  ...
}: {
  home.packages = with pkgs; [
    (pkgs.callPackage ../../common/pm {})
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
    imv
    tauon
    mpv
    dragon-drop
    telegram-desktop
    google-chrome
    element-desktop
    gimp3
    easyeffects
    pkgs-unstable.thunderbird-bin
    gh

    # fonts
    nerd-fonts.fira-mono
    google-fonts
    noto-fonts-color-emoji

    darktable
  ];
}
