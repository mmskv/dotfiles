{pkgs, ...}: let
  # This is the one display/UI scaling control (for example: 1.25 or 1.5).
  # Hyprland applies it to every Wayland client. Keep the application sizes
  # below in logical pixels so they are not scaled twice.
  uiScale = 1.0;
in {
  _module.args.desktopTheme = {
    inherit uiScale;

    # Hex colors intentionally omit "#" because each consumer has a different
    # syntax (CSS #RRGGBB, Hyprland rgb(), Fuzzel RRGGBBAA, and so on).
    colors = {
      accent = "EA803F";
      accentMuted = "9C7446";
      activeBorder = "4B5366";
      background = "141414";
      border = "212121";
      foreground = "C5C8C6";
      foregroundWarm = "DCD7BA";
      prompt = "8C9440";
      white = "FFFFFF";
      black = "000000";

      calendar = {
        months = "FFEAD3";
        weekdays = "FFCC66";
      };

      document = {
        background = "0D0F11";
        foreground = "F0F0F0";
      };

      terminal = {
        background = "141212";
        bright = {
          black = "373B41";
          blue = "81A2BE";
          cyan = "8ABEB7";
          green = "B5BD68";
          magenta = "B294BB";
          red = "CC6666";
          white = "C5C8C6";
          yellow = "F0C674";
        };
        dim = {
          black = "282A2E";
          blue = "5F819D";
          cyan = "5E8D87";
          green = "8C9440";
          magenta = "85678F";
          red = "A54242";
          white = "707880";
          yellow = "DE935F";
        };
      };

      battery = {
        "100" = "FFFFFF";
        "90" = "FFF7F7";
        "80" = "FFEEEE";
        "70" = "FFE5E5";
        "60" = "FFDADA";
        "50" = "FFCFCF";
        "40" = "FFC1C1";
        "30" = "FFB1B1";
        "20" = "FF9D9D";
        "10" = "FF7F7F";
        "0" = "FF0000";
      };
    };

    fonts = {
      ui = "Fira Mono";
      terminal = "FiraMono Nerd Font";
      packages = with pkgs; [
        nerd-fonts.fira-mono
        google-fonts
        noto-fonts-color-emoji
      ];
    };

    cursor = {
      name = "phinger-cursors-dark";
      package = pkgs.phinger-cursors;
      size = 24;
    };

    gtk = {
      theme = {
        name = "Kanagawa-BL";
        package = pkgs.kanagawa-gtk-theme;
      };
      icons = {
        name = "Papirus";
        package = pkgs.papirus-icon-theme;
      };
    };

    metrics = {
      terminal = {
        fontSize = 10;
        padding = 18;
      };
      launcher = {
        fontSize = 11;
        horizontalPadding = 8;
        verticalPadding = 8;
      };
      bar = {
        fontSize = 14;
        clockFontSize = 16;
        privacyIconSize = 14;
        tooltipIconSize = 24;
        trayIconSize = 16;
      };
      sharePicker = {
        height = 500;
        width = 1000;
        previewSize = 300;
        widgetSize = 150;
      };
    };
  };
}
