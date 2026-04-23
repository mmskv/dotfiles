{
  pkgs,
  pkgs-unstable,
  ...
}: {
  home.packages = with pkgs; [
    xfce.thunar
    xfce.thunar-volman
    pavucontrol
    playerctl
    libreoffice-qt
    hunspell
    hunspellDicts.en_US
    hunspellDicts.ru_RU
    playerctl
    pamixer
    neofetch
    btop
    imv
    tauon
    mpv
    dragon-drop
    telegram-desktop
    google-chrome
    element-desktop
    gimp3
    terraform
    pkgs-unstable.glab

    pkgs-unstable.obsidian

    # fonts
    fira
    nerd-fonts.fira-mono
    google-fonts
    geist-font
    noto-fonts-color-emoji

    darktable
  ];
}
