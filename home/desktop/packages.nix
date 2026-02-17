{pkgs, ...}: {
  home.packages = with pkgs; [
    obsidian
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

    # fonts
    fira
    nerd-fonts.fira-mono
    google-fonts
    geist-font
    noto-fonts-color-emoji

    darktable
  ];
}
