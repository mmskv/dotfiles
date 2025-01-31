{
  pkgs,
  sec,
  ...
}: let
  modules-left = [
    "hyprland/workspaces"
    "hyprland/window"
  ];
  "hyprland/workspaces" = {
    format = "{icon}";
    on-click = "activate";
    all-outputs = false;
    format-icons = {
      "1" = "1";
      "2" = "2";
      "3" = "3";
      "4" = "4";
      "5" = "5";
      "6" = "6";
      "7" = "7";
      "8" = "8";
      "9" = "9";
      "10" = "1";
      "11" = "2";
      "12" = "3";
      "13" = "4";
      "14" = "5";
      "15" = "6";
      "16" = "7";
      "17" = "8";
      "18" = "9";
    };
  };
  "hyprland/window" = {
    format = "";
    separate-outputs = true;
  };
in {
  programs.waybar = {
    enable = true;
    systemd.enable = true;
    systemd.target = "hyprland-session.target";

    settings = [
      {
        layer = "top";
        position = "right";
        output = "DP-1";
        reload_style_on_change = true;
        modules-right = [
          "privacy#screenshare"
          "privacy#audio"
          "custom/vpn"
          "pulseaudio/slider"
          "clock"
        ];

        inherit modules-left;
        inherit "hyprland/window";
        inherit "hyprland/workspaces";

        "privacy#audio" = {
          icon-spacing = 4;
          icon-size = 14;
          transition-duration = 250;
          modules = [
            {
              type = "audio-in";
              tooltip = true;
              tooltip-icon-size = 24;
            }
          ];
        };

        "privacy#screenshare" = {
          icon-spacing = 4;
          icon-size = 14;
          transition-duration = 250;
          modules = [
            {
              type = "screenshare";
              tooltip = true;
              tooltip-icon-size = 24;
            }
          ];
        };

        "custom/vpn" = {
          format = "{}";
          return-type = "json";
          interval = 2;
          exec = pkgs.writeShellScript "vpn-check" ''
            if output=$(${pkgs.dogdns}/bin/dog o-o.myaddr.l.google.com --tls @dns.google txt -1 2>/dev/null); then
                echo "$output" | grep -q ${sec.mysubnet} && \
                echo '{"text": "V", "class": "off"}' || echo '{"text": "V", "class": "on"}'
            else
                echo '{"text": "O", "class": "error"}'
            fi'';
          on-scroll-up = pkgs.writeShellScript "vpn-start" sec.vpn.startcmd;
          on-scroll-down = pkgs.writeShellScript "vpn-stop" sec.vpn.stopcmd;
        };

        "pulseaudio/slider" = {
          orientation = "vertical";
          on-click = "pavucontrol && hyprctl dispatch focuswindow pavucontrol";
        };

        clock = {
          format = ''
            {:%H
            %M}'';
          interval = 1;
          tooltip-format = "<tt>{calendar}</tt>";
          locale = "en_GB.utf8";
          calendar = {
            mode = "year";
            mode-mon-col = 3;
            on-scroll = 1;
            on-click-right = "mode";
            format = {
              today = "<span color='#EA803F'><b>{}</b></span>";
              months = "<span color='#ffead3'><b>{}</b></span>";
              weekdays = "<span color='#ffcc66'><b>{}</b></span>";
            };
          };
          actions = {
            on-scroll-up = "shift_up";
            on-scroll-down = "shift_down";
          };
        };
      }
      {
        layer = "top";
        output = "!DP-1";
        position = "right";
        reload_style_on_change = true;

        inherit modules-left;
        inherit "hyprland/window";
        inherit "hyprland/workspaces";
      }
    ];
    style = ''
      @define-color active #EA803F;
      @define-color urgent #204D15;
      @define-color bg #141414;
      @define-color fg #C5C8C6;
      @define-color border #212121;

      * {
        font-size: 14px;
        font-family: "Fira Mono";
      }

      window#waybar {
        background: @bg;
        border-left: 1px solid @border;
      }

      #workspaces {
        margin: 4px 0px;
      }

      #workspaces button {
        transition-property: background-color;
        transition-duration: 0;
        box-shadow: inherit;
        text-shadow: inherit;
        color: inherit;
        padding: 0px 2px 0px 4px;
        border-radius: 0;
      }

      #workspaces button.urgent {
        color: @urgent;
      }

      window#waybar.fullscreen #workspaces button.active {
        background: linear-gradient(to right, @active 50%, transparent 50%);
        background-size: 200% 100%;
        background-position: left bottom;
        transition: background-position 0.3s cubic-bezier(0.33, 1, 0.68, 1);
      }

      #workspaces button.active {
        padding-left: 2px;
        border-left: 2px solid @active;
      }

      #workspaces button.empty {
        color: @border;
      }

      .other#workspaces button.active {
        padding-left: 0px;
        padding-right: 2px;
        border-right: 2px solid @active;
      }

      #clock {
        font-weight: bolder;
        font-size: 16px;
        padding: 16px 5px 3px 5px;
      }

      #pulseaudio-slider {
        padding: 10px 0px 8px 0px;
      }

      #pulseaudio-slider slider {
        background: none;
        min-height: 0px;
        min-width: 0px;
        opacity: 0;
        background-image: none;
        border: none;
        box-shadow: none;
      }

      #pulseaudio-slider trough {
        min-height: 80px;
        min-width: 4px;
        border-radius: 5px;
        background: black;
      }

      #pulseaudio-slider highlight {
        border-radius: 5px;
        background: @active;
      }

      #privacy-item {
        padding: 8px 8px;
      }

      #custom-vpn {
        padding: 7px 0px;
        font-weight: bold;
      }

      #custom-vpn.on {
        color: @active;
      }

      #custom-vpn.off {
        color: @border;
      }

      #custom-vpn.error {
        color: @fg;
      }
    '';
  };
}
