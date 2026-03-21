{
  pkgs,
  pkgs-unstable,
  lib,
  config,
  sec,
  ...
}: let
  isLaptop = config.custom.workLaptop.enable;
  isDesktop = !isLaptop;

  modules-left = [
    "hyprland/workspaces"
    "hyprland/window" # for workspace states (fullscreen/empty)
  ];

  modules-right =
    [
      "privacy#screenshare"
      "privacy#audio"
    ]
    ++ (
      if isLaptop
      then ["tray" "battery"]
      else ["custom/vpn"]
    )
    ++ [
      "hyprland/language"
      "pulseaudio/slider"
      "clock"
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

  primaryOutput = ["eDP-1" "DP-1" "DP-2"];

  secondaryRightOutput = "DP-3";
  secondaryTopOutput = ["HDMI-A-1" "HDMI-A-2"];
in {
  programs.waybar = {
    enable = true;
    systemd.enable = true;
    systemd.target = "hyprland-session.target";

    settings = [
      {
        output = primaryOutput;

        layer = "top";
        position = "right";
        reload_style_on_change = true;

        inherit modules-left;
        inherit modules-right;
        inherit "hyprland/workspaces";
        inherit "hyprland/window";

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

        "hyprland/language" = {
          format-en = "E";
          format-ru = "R";
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

        battery = {
          interval = 30;
          format = "B";
          format-charging = "C";
          tooltip-format = "{capacity}% {time}";
          states = {
            "capacity-0" = 0;
            "capacity-10" = 10;
            "capacity-20" = 20;
            "capacity-30" = 30;
            "capacity-40" = 40;
            "capacity-50" = 50;
            "capacity-60" = 60;
            "capacity-70" = 70;
            "capacity-80" = 80;
            "capacity-90" = 90;
            "capacity-100" = 100;
          };
        };

        tray = {
          icon-size = 16;
          spacing = 8;
          show-passive-items = true;
        };
      }

      {
        layer = "top";
        position = "top";
        reload_style_on_change = true;

        output = secondaryTopOutput;

        inherit modules-left;
        inherit "hyprland/workspaces";
        inherit "hyprland/window";
      }

      {
        layer = "top";
        position = "right";
        reload_style_on_change = true;

        output = secondaryRightOutput;

        inherit modules-left;
        inherit "hyprland/workspaces";
        inherit "hyprland/window";
      }
    ];
    style =
      # css
      ''
        @define-color active #EA803F;
        @define-color bg #141414;
        @define-color fg #DCD7BA;
        @define-color border #212121;

        * {
          font-size: 14px;
          font-family: "Fira Mono";
          border: 0px;
          padding: 0px;
          border-radius: 0;
        }

        window { background: @bg; }

        window#waybar.right .modules-left { padding: 2px 0px 0px 0px; }
        window#waybar.top   .modules-left { padding: 0px 0px 0px 2px; }

        window#waybar.right .modules-right > * { padding: 2px 3px 2px 3px; }
        window#waybar.top   .modules-right > * { padding: 0px 2px 0px 2px; }

        window#waybar.right { border-left: 1px solid @border; }
        window#waybar.top { border-bottom: 1px solid @border; }

        window#waybar.right button { padding: 0px 4px 0px 6px; }
        window#waybar.top   button { padding: 2px 0px 4px 0px; }

        window#waybar.right #workspaces button.active {
          padding-left: 4px;
          border-left: 2px solid @active;
        }
        window#waybar.top #workspaces button.active {
          padding-bottom: 2px;
          border-bottom: 2px solid @active;
        }

        window#waybar.fullscreen #workspaces button.active {
          background: linear-gradient(to right, @active 50%, transparent 50%);
          background-size: 200% 100%;
          background-position: left bottom;
          transition: background-position 0.3s cubic-bezier(0.33, 1, 0.68, 1);
        }

        #workspaces button {
          transition-property: background-color;
          transition-duration: 0;
          color: @fg;
        }
        #workspaces button.urgent { color: @active; }
        #workspaces button.empty  { color: @border; }

        #clock {
          font-weight: bold;
          font-size: 16px;
          padding: 3px 5px 3px 7px;
          color: @fg;
        }


        #pulseaudio-slider {
            padding: 10px 0px 10px 1px;
        }

        #pulseaudio-slider slider {
          background: none;
          min-height: 0px;
          min-width: 0px;
          opacity: 0;
          background-image: none;
          border: none;
          box-shadow: none;
          padding: 0px;
        }

        #pulseaudio-slider trough {
          min-height: 80px;
          min-width: 3px;
          border-radius: 5px;
          background: black;
        }

        #pulseaudio-slider highlight {
          border-radius: 5px;
          background: @active;
          padding: 0px;
        }


        #language { font-weight: bold; }

        #custom-vpn { font-weight: bold; }
        #custom-vpn.on { color: @active; }
        #custom-vpn.off { color: @border; }
        #custom-vpn.error { color: @fg; }

        #tray * { padding: 0px; }
        #tray { padding: 4px 0px 4px 1.5px; margin: 4px 0px; }

        #battery { font-weight: bold; }

        #battery.capacity-100 { color: #ffffff; }
        #battery.capacity-90 { color: #fff7f7; }
        #battery.capacity-80 { color: #ffeeee; }
        #battery.capacity-70 { color: #ffe5e5; }
        #battery.capacity-60 { color: #ffdada; }
        #battery.capacity-50 { color: #ffcfcf; }
        #battery.capacity-40 { color: #ffc1c1; }
        #battery.capacity-30 { color: #ffb1b1; }
        #battery.capacity-20 { color: #ff9d9d; }
        #battery.capacity-10 { color: #ff7f7f; }
        #battery.capacity-0 { color: #ff0000; }
      '';
  };
}
