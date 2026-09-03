{lib, ...}: {
  programs.alacritty = {
    enable = true;

    settings = {
      font = {
        size = lib.mkDefault 10;
        offset = {
          x = 0;
          y = -1;
        };
        glyph_offset = {
          x = 0;
          y = 0;
        };
        bold = {
          family = "FiraMono Nerd Font";
          style = "Bold";
        };
        normal = {
          family = "FiraMono Nerd Font";
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
          x = 18;
          y = 18;
        };
        dimensions = {
          columns = 0;
          lines = 0;
        };
      };

      colors = {
        draw_bold_text_with_bright_colors = false;
        bright = {
          black = "0x373B41";
          blue = "0x81A2BE";
          cyan = "0x8ABEB7";
          green = "0xB5BD68";
          magenta = "0xB294BB";
          red = "0xCC6666";
          white = "0xC5C8C6";
          yellow = "0xF0C674";
        };
        dim = {
          black = "0x282A2E";
          blue = "0x5F819D";
          cyan = "0x5E8D87";
          green = "0x8C9440";
          magenta = "0x85678F";
          red = "0xA54242";
          white = "0x707880";
          yellow = "0xDE935F";
        };
        primary = {
          background = "0x141212";
          foreground = "0xC5C8C6";
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
