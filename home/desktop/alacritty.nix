{
  desktopTheme,
  lib,
  ...
}: let
  inherit (desktopTheme) colors fonts metrics;
  hex = color: "0x${color}";
in {
  programs.alacritty = {
    enable = true;

    settings = {
      font = {
        size = lib.mkDefault metrics.terminal.fontSize;
        offset = {
          x = 0;
          y = -1;
        };
        glyph_offset = {
          x = 0;
          y = 0;
        };
        bold = {
          family = fonts.terminal;
          style = "Bold";
        };
        normal = {
          family = fonts.terminal;
          style = "Regular";
        };
      };

      keyboard.bindings = [
        {
          action = "ToggleViMode";
          key = "Insert";
          mods = "Shift";
          mode = "~Search";
        }
        {
          action = "Copy";
          key = "С";
          mods = "Control|Shift";
        }
      ];

      mouse.hide_when_typing = false;
      scrolling = {
        history = 100000;
        multiplier = 4;
      };

      window = {
        decorations = "none";
        dynamic_padding = false;
        opacity = 1.0;
        startup_mode = "Windowed";
        padding = {
          x = metrics.terminal.padding;
          y = metrics.terminal.padding;
        };
        dimensions = {
          columns = 0;
          lines = 0;
        };
      };

      colors = {
        draw_bold_text_with_bright_colors = false;
        bright = {
          black = hex colors.terminal.bright.black;
          blue = hex colors.terminal.bright.blue;
          cyan = hex colors.terminal.bright.cyan;
          green = hex colors.terminal.bright.green;
          magenta = hex colors.terminal.bright.magenta;
          red = hex colors.terminal.bright.red;
          white = hex colors.terminal.bright.white;
          yellow = hex colors.terminal.bright.yellow;
        };
        dim = {
          black = hex colors.terminal.dim.black;
          blue = hex colors.terminal.dim.blue;
          cyan = hex colors.terminal.dim.cyan;
          green = hex colors.terminal.dim.green;
          magenta = hex colors.terminal.dim.magenta;
          red = hex colors.terminal.dim.red;
          white = hex colors.terminal.dim.white;
          yellow = hex colors.terminal.dim.yellow;
        };
        primary = {
          background = hex colors.terminal.background;
          foreground = hex colors.foreground;
        };
      };

      debug = {
        log_level = "OFF";
        persistent_logging = false;
        print_events = false;
        render_timer = false;
      };

      terminal.osc52 = "Disabled";
    };
  };
}
