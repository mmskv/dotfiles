{
  desktopTheme,
  pkgs,
  pkgs-unstable,
  lib,
  config,
  sec,
  ...
}: let
  inherit (desktopTheme) colors fonts metrics;
  isLaptop = config.custom.workLaptop.enable;
  isDesktop = !isLaptop;
  vpnSubnetArgs = lib.escapeShellArgs (lib.concatMap (subnet: ["-e" subnet]) sec.mysubnets);

  vpnStatus = pkgs.writeShellApplication {
    name = "waybar-vpn-status";
    runtimeInputs = with pkgs; [
      doggo
      gnugrep
    ];
    text = ''
      if output=$(doggo --short --timeout 1s --type TXT o-o.myaddr.l.google.com @tls://dns.google 2>/dev/null); then
        if printf '%s\n' "$output" | grep -q ${vpnSubnetArgs}; then
          printf '%s\n' '{"text":"V","class":"off"}'
        else
          printf '%s\n' '{"text":"V","class":"on"}'
        fi
      else
        printf '%s\n' '{"text":"O","class":"error"}'
      fi
    '';
  };

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

  primaryOutput = ["eDP-1" "DP-1" "DP-2" "DP-4"];

  secondaryTopOutput = ["HDMI-A-1" "HDMI-A-2" "DP-3"];
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
          icon-size = metrics.bar.privacyIconSize;
          transition-duration = 250;
          modules = [
            {
              type = "audio-in";
              tooltip = true;
              tooltip-icon-size = metrics.bar.tooltipIconSize;
            }
          ];
        };

        "privacy#screenshare" = {
          icon-spacing = 4;
          icon-size = metrics.bar.privacyIconSize;
          transition-duration = 250;
          modules = [
            {
              type = "screenshare";
              tooltip = true;
              tooltip-icon-size = metrics.bar.tooltipIconSize;
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
          interval = 60;
          tooltip-format = "<tt>{calendar}</tt>";
          locale = "en_GB.utf8";
          calendar = {
            mode = "year";
            mode-mon-col = 3;
            on-scroll = 1;
            on-click-right = "mode";
            format = {
              today = "<span color='#${colors.accent}'><b>{}</b></span>";
              months = "<span color='#${colors.calendar.months}'><b>{}</b></span>";
              weekdays = "<span color='#${colors.calendar.weekdays}'><b>{}</b></span>";
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
          interval = 5;
          exec = "${vpnStatus}/bin/waybar-vpn-status";
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
          icon-size = metrics.bar.trayIconSize;
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
    ];
    style =
      # css
      ''
        @define-color active #${colors.accent};
        @define-color bg #${colors.background};
        @define-color fg #${colors.foregroundWarm};
        @define-color border #${colors.border};

        * {
          font-size: ${toString metrics.bar.fontSize}px;
          font-family: "${fonts.ui}";
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
          font-size: ${toString metrics.bar.clockFontSize}px;
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
          background: #${colors.black};
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

        #battery.capacity-100 { color: #${colors.battery."100"}; }
        #battery.capacity-90 { color: #${colors.battery."90"}; }
        #battery.capacity-80 { color: #${colors.battery."80"}; }
        #battery.capacity-70 { color: #${colors.battery."70"}; }
        #battery.capacity-60 { color: #${colors.battery."60"}; }
        #battery.capacity-50 { color: #${colors.battery."50"}; }
        #battery.capacity-40 { color: #${colors.battery."40"}; }
        #battery.capacity-30 { color: #${colors.battery."30"}; }
        #battery.capacity-20 { color: #${colors.battery."20"}; }
        #battery.capacity-10 { color: #${colors.battery."10"}; }
        #battery.capacity-0 { color: #${colors.battery."0"}; }
      '';
  };
}
