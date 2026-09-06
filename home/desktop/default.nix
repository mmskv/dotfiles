{
  config,
  desktopTheme,
  ...
}: {
  imports = [
    ../minimal

    ./theme.nix
    ./packages.nix
    ./mouse-gestures.nix
    ./hyprland.nix
    ./screen-sharing.nix
    ./waybar.nix
    ./zathura.nix
    ./imv.nix
    ./fuzzel.nix
    ./alacritty.nix
    ./telegram.nix
    ./xdg-open-in-vim.nix
    ./syncthing.nix
    ./bluelight.nix
    ./xkb.nix
    ./cal.nix
    ./thunar.nix

    ./firefox
  ];

  home = {
    sessionVariables = {
      NIXOS_OZONE_WL = "1";
    };

    pointerCursor = {
      inherit (desktopTheme.cursor) name package size;
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
      inherit (desktopTheme.gtk.theme) name package;
    };

    gtk4.theme = config.gtk.theme;

    iconTheme = {
      inherit (desktopTheme.gtk.icons) name package;
    };
  };

  fonts.fontconfig.enable = true;
}
