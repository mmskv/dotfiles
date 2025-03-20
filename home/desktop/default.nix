{
  pkgs,
  pkgs-unstable,
  ...
}: {
  imports = [
    ../minimal

    ./hyprland.nix
    ./waybar.nix
    ./zathura.nix
    ./fuzzel.nix
    ./alacritty.nix
    ./telegram.nix
    ./xdg-open-in-vim.nix
  ];

  home = {
    sessionVariables = {
      NIXOS_OZONE_WL = "1";
      FLAKE = "/home/suck/dotfiles";
    };

    pointerCursor = {
      name = "phinger-cursors-dark";
      package = pkgs.phinger-cursors;
      size = 24;
      x11.enable = true;
      gtk.enable = true;
    };
  };

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "application/pdf" = ["org.pwmt.zathura.desktop"];
      "application/epub" = ["org.pwmt.zathura.desktop"];
      "x-scheme-handler/http" = ["firefox.desktop"];
      "x-scheme-handler/https" = ["firefox.desktop"];
      "x-scheme-handler/chrome" = ["firefox.desktop"];
      "text/html" = ["firefox.desktop"];
      "image/png" = ["imv-dir.desktop"];
      "image/jpeg" = ["imv-dir.desktop"];
      "image/gif" = ["imv-dir.desktop"];
      "x-scheme-handler/tg" = ["org.telegram.desktop.desktop"];
      "x-scheme-handler/tonsite" = ["org.telegram.desktop.desktop"];
    };
  };

  gtk = {
    enable = true;
    theme = {
      name = "Kanagawa-BL";
      package = pkgs.kanagawa-gtk-theme;
    };

    iconTheme = {
      name = "Papirus";
      package = pkgs.papirus-icon-theme;
    };
  };

  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    # user
    alacritty
    obsidian
    xfce.thunar
    xfce.thunar-volman
    pavucontrol
    playerctl
    libreoffice-qt
    hunspell
    hunspellDicts.en_US
    hunspellDicts.ru_RU
    code-cursor
    playerctl
    pamixer
    neofetch
    btop
    imv
    tauon
    mpv
    xdragon
    telegram-desktop
    google-chrome
    element-desktop
    gh
    gh-copilot

    # fonts
    fira
    nerdfonts
    noto-fonts-emoji

    # unstable
    pkgs-unstable.darktable
  ];
}
