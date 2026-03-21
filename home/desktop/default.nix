{pkgs, ...}: {
  imports = [
    ../minimal

    ./packages.nix
    ./hyprland.nix
    ./waybar.nix
    ./zathura.nix
    ./fuzzel.nix
    ./alacritty.nix
    ./telegram.nix
    ./xdg-open-in-vim.nix
    ./syncthing.nix
    ./bluelight.nix
    ./vscode.nix
    ./xkb.nix
    ./cal.nix

    ./firefox
  ];

  home = {
    sessionVariables = {
      NIXOS_OZONE_WL = "1";
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
      "x-scheme-handler/file" = ["org.xfce.thunar.desktop"];
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
}
