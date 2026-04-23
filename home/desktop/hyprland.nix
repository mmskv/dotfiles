{
  lib,
  pkgs,
  pkgs-unstable,
  hyprlandPackages,
  config,
  nixgl,
  ...
}: let
  isLaptop = config.custom.workLaptop.enable;
  xdph = hyprlandPackages.hyprland-xdph;

  screenshot_name = ''$HOME"/screenshots/Screenshot $(date +%F) at $(date +%T).png"'';

  brightness-script = pkgs.writeShellScriptBin "brightness-notify" ''
    export PATH=${pkgs.lib.makeBinPath [pkgs.brightnessctl pkgs.libnotify]}:$PATH
    brightnessctl set "$1"
    current=$(brightnessctl get)
    max=$(brightnessctl max)
    percent=$(( current * 100 / max ))
    notify-send -t 1000 \
      -h string:x-canonical-private-synchronous:brightness \
      -h int:value:$percent \
      "Brightness: $percent%"
  '';

  clipse = pkgs.buildGoModule rec {
    pname = "clipse";
    version = "1.2.1";

    src = pkgs.fetchFromGitHub {
      owner = "savedra1";
      repo = "clipse";
      rev = "v${version}";
      hash = "sha256-iDMHEhYuxspBYG54WivnVj2GfMxAc5dcrjNxtAMhsck=";
    };

    vendorHash = "sha256-rq+2UhT/kAcYMdla+Z/11ofNv2n4FLvpVgHZDe0HqX4=";

    tags = ["wayland"];

    env = {
      CGO_ENABLED = "0";
    };

    meta = {
      description = "Configurable TUI clipboard manager for Unix";
      homepage = "https://github.com/savedra1/clipse";
      license = pkgs.lib.licenses.mit;
      mainProgram = "clipse";
    };
  };

  uwsm = "uwsm app -- ";

  monitor-event-handler = pkgs.writeShellScriptBin "monitor-event-handler" ''
    ${pkgs.socat}/bin/socat -U - UNIX-CONNECT:"$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" | while IFS= read -r line; do
      case "$line" in
        monitorremoved*|monitoradded*)
          sleep 1
          systemctl --user restart hyprsunset.service
          sleep 2
          systemctl --user start brightness-update.service
          ;;
      esac
    done
  '';

  lid-close-script = pkgs.writeShellScriptBin "lid-close" ''
    # Only disable laptop screen if an external monitor is connected
    external=$(${pkgs.hyprland}/bin/hyprctl -j monitors | ${pkgs.jq}/bin/jq '[.[] | select(.name != "eDP-1")] | length')
    if [ "$external" -gt 0 ]; then
      ${pkgs.hyprland}/bin/hyprctl keyword monitor eDP-1,disable
      systemctl restart --user waybar
    fi
  '';

  nixGLIntel = pkgs.nixgl.nixGLIntel;

  # Systemd drop-in that replaces ExecStart with a Nix binary.
  # On non-NixOS, system units point at /usr/bin/* which may not match
  # the Nix client libraries.
  mkExecOverride = service: cmd: {
    "systemd/user/${service}.service.d/override.conf".text = ''
      [Service]
      ExecStart=
      ExecStart=${cmd}
    '';
  };
in {
  targets.genericLinux.nixGL = {
    packages = nixgl.packages;
    defaultWrapper = "mesa";
  };

  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;
    systemd.enable = true;

    package =
      if isLaptop
      then config.lib.nixGL.wrap hyprlandPackages.hyprland-pkg
      else null;
    portalPackage =
      if isLaptop
      then hyprlandPackages.hyprland-xdph
      else null;

    plugins = [
      hyprlandPackages.hyprsplit-pkg
      hyprlandPackages.hy3-pkg
    ];

    settings = {
      exec-once =
        [
          "hyprctl setcursor phinger-cursors-dark 24"
          "${uwsm} wl-clip-persist --clipboard both"
        ]
        ++ lib.optionals isLaptop [
          "${uwsm} nm-applet --indicator"
          "${uwsm} blueman-applet"
          "${monitor-event-handler}/bin/monitor-event-handler"
        ];

      input =
        {
          kb_layout = "uscustom,rucustom";
          kb_options = "grp:ctrl_space_toggle,caps:escape";
          repeat_delay = 380;
          repeat_rate = 35;
        }
        // lib.optionalAttrs isLaptop {
          touchpad = {
            natural_scroll = true;
            disable_while_typing = true;
            tap-to-click = true;
          };
        };

      cursor.inactive_timeout = 3;

      general = {
        layout = "hy3";
        gaps_in = 0;
        gaps_out = 0;
        "col.active_border" = "rgb(4b5366) rgb(9c7446) 45deg";
        "col.inactive_border" = "0xff212121";
      };

      group = {
        "col.border_active" = "rgb(4b5366)";
        "col.border_inactive" = "0xff212121";
      };

      misc = {
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
        disable_autoreload = true;
        enable_anr_dialog = false;
        size_limits_tiled = true;
        animate_manual_resizes = true;
      };

      animations = {
        enabled = true;

        bezier = [
          "fluent_decel, 0, 0.2, 0.4, 1"
          "easeOutCirc, 0, 0.55, 0.45, 1"
          "easeOutCubic, 0.33, 1, 0.68, 1"
          "fade_curve, 0, 0.55, 0.45, 1"
        ];

        animation =
          [
            # name, enable, speed, curve, style

            "windowsIn,   0" # window open
            "windowsOut,  0" # window close.
            "windowsMove, 1, 0.7, fluent_decel, slide" # everything in between: moving, dragging, resizing.

            "fade,        0"
            "border,      1, 1.7, easeOutCirc" # for animating the border's color switch speed
            "borderangle, 1, 10,  fluent_decel, once" # for animating the border's gradient angle - styles: once (default), loop
          ]
          ++ (
            if isLaptop
            then [
              "workspaces,  1, 3.5, easeOutCubic, slide"
            ]
            else [
              "workspaces,  1, 3.5, easeOutCubic, slidevert"
            ]
          );
      };

      decoration = {
        border_part_of_window = false;

        blur = {
          enabled = true;
          size = 3;
          passes = 2;
          brightness = 1;
          contrast = 1.4;
          noise = 0;
          new_optimizations = true;
          xray = false;
        };
      };

      binds.scroll_event_delay = 2;

      bind =
        [
          # keybindings
          "SUPER, Return, exec, ${uwsm} alacritty"
          "SUPER, B, exec, ${uwsm} ${nixGLIntel}/bin/nixGLIntel firefox"
          "SUPER SHIFT, B, exec, ${uwsm} ${nixGLIntel}/bin/nixGLIntel google-chrome-stable --enable-features=VaapiVideoDecodeLinuxGL --use-gl=angle --use-angle=gl --ozone-platform=wayland"
          "SUPER, Q, killactive,"
          "SUPER, F, fullscreen, 1"
          "SUPER, Space, togglefloating"
          "SUPER, P, exec, ${uwsm} fuzzel"
          "SUPER, Escape, exec, ${uwsm} alacritty --class clipse -e 'clipse'"

          "SUPER, comma, focusmonitor, +1"
          "SUPER SHIFT, comma, movewindow, mon:+1"

          "SUPER, X, split:swapactiveworkspaces, current +1"

          "SUPER, mouse_down, workspace, -1"
          "SUPER, mouse_up, workspace, +1"
          "SUPER, mouse_left, focusmonitor, -1"
          "SUPER, mouse_right, focusmonitor, +1"

          # hillside binds
          ",Print, exec, ${uwsm} grimblast copy active"
          ",XF86Screensaver, exec, ${uwsm} grimblast save active ${screenshot_name}"
          "SHIFT ,Print, exec, ${uwsm} grimblast copy area"
          "SHIFT ,XF86Screensaver, exec, ${uwsm} grimblast save area ${screenshot_name}"

          "SUPER, Tab, changegroupactive, f"
          "SUPER SHIFT, Tab, changegroupactive, b"

          "SUPER, I, hy3:equalize"

          "SUPER, S, hy3:changefocus, lower"
          "SUPER, W, hy3:changefocus, raise"

          "SUPER, V, hy3:makegroup, v, ephemeral"
          "SUPER, C, hy3:makegroup, h, ephemeral"

          "SUPER, H, hy3:movefocus, l"
          "SUPER, J, hy3:movefocus, d"
          "SUPER, K, hy3:movefocus, u"
          "SUPER, L, hy3:movefocus, r"

          "SUPER SHIFT, H, hy3:movewindow, l"
          "SUPER SHIFT, J, hy3:movewindow, d"
          "SUPER SHIFT, K, hy3:movewindow, u"
          "SUPER SHIFT, L, hy3:movewindow, r"

          ",XF86AudioMute,exec, pamixer -t"
          ",XF86AudioMicMute,exec, pamixer --default-source -t"
          ",XF86AudioPlay,exec, playerctl play-pause"
          ",XF86AudioNext,exec, playerctl next"
          ",XF86AudioPrev,exec, playerctl previous"
        ]
        ++ (map (i: "SUPER, ${toString i}, split:workspace, ${toString i}") (lib.range 1 9))
        ++ (map (i: "SUPER CTRL, ${toString i}, split:movetoworkspacesilent, ${toString i}") (lib.range 1 9))
        ++ (map (i: "SUPER SHIFT, ${toString i}, split:movetoworkspacesilent, ${toString i}") (lib.range 1 9))
        # map to hillside numpad
        ++ (lib.imap1 (i: key: "SUPER CTRL, ${key}, split:workspace, ${toString i}") ["x" "c" "v" "s" "d" "f" "w" "e" "r"]);

      # binds that repeat when held
      binde =
        [
          ",XF86AudioRaiseVolume,exec, pamixer -u -i 5"
          ",XF86AudioLowerVolume,exec, pamixer -u -d 5"

          "SUPER CTRL, H, resizeactive, -150 0"
          "SUPER CTRL, J, resizeactive, 0 -100"
          "SUPER CTRL, K, resizeactive, 0 100"
          "SUPER CTRL, L, resizeactive, 150 0"
        ]
        ++ lib.optionals isLaptop [
          ",XF86MonBrightnessUp,exec, ${brightness-script}/bin/brightness-notify +5%"
          ",XF86MonBrightnessDown,exec, ${brightness-script}/bin/brightness-notify 5%-"
        ];

      # mouse binding
      bindm = [
        "SUPER, mouse:272, movewindow"
        "SUPER, mouse:273, resizewindow"
      ];

      # lid switch
      bindl = lib.optionals isLaptop [
        ",switch:on:Lid Switch, exec, ${lid-close-script}/bin/lid-close"
        ",switch:off:Lid Switch, exec, hyprctl keyword monitor eDP-1, preferred, auto-left, 2 && systemctl restart --user waybar"
      ];

      gesture = [
        "3, horizontal, workspace"
        "3, up, fullscreen"
        "3, down, fullscreen"
      ];

      # windowrulev2
      windowrule =
        [
          "match:class ^tauonmb$, workspace 5"
          "match:class ^org.telegram.desktop$, workspace 1"
          "match:class ^firefox$, idle_inhibit fullscreen"
          "match:class ^mpv$, idle_inhibit focus"

          "match:title ^Enter name of file to save, size 500 700"

          "match:class ^clipse$, float on, border_size 1, size 800 700, opacity 0.8, rounding 10"

          "match:class ^org.telegram.desktop$, match:title ^Media viewer$, fullscreen on"

          "match:workspace w[v1], border_size 0"
        ]
        ++ (map (c: "match:class ^${c}$, float on") [
          "pavucontrol"
          "file_progress"
          "confirm"
          "dialog"
          "download"
          "notification"
          "error"
          "confirmreset"
        ])
        ++ (map (t: "match:title ^${t}$, float on") [
          "Open File"
          "Choose Files"
          "File Upload"
          "branchdialog"
          "Confirm to replace files"
          "File Operation Progress"
          "Volume Control"
        ]);
    };

    extraConfig =
      (
        if isLaptop
        then ''
          monitor=eDP-1,preferred,auto,2
          monitor=DP-1,highrr,auto-center-up,1,bitdepth,10
          monitor=,preferred,auto,1
        ''
        else ''
          monitor=DP-1,3440x1440@144,0x0,1
          monitor=HDMI-A-1,3440x1440@99.99,3440x-720,1,transform,1
        ''
      )
      + ''

        xwayland {
          force_zero_scaling = true
        }

        plugin {
          hyprsplit {
            persistent_workspaces = true
            num_workspaces = 9
          }

          hy3 {
            no_gaps_when_only = 0
            node_collapse_policy = 0
            group_inset = 0
            tab_first_window = false

            tabs {
              height = 0
              padding = 0
              render_text = false
            }

            autotile {
              enable = true
              trigger_width = 600
              trigger_height = 400
            }
          }
        }
      '';
  };

  services.hyprpaper = {
    enable = true;
    settings = {
      ipc = "off";
      preload = ["${../../wallpaper.jpg}" "${../../wallpaper2.jpg}"];
      wallpaper = [",${../../wallpaper.jpg}" "HDMI-A-1,${../../wallpaper2.jpg}"];
    };
  };

  services.mako = {
    enable = true;
    settings = {
      font = "Fira Mono";
      background-color = "#141414ff";
      text-color = "#C5C8C6ff";
      border-color = "#EA803Fff";
      default-timeout = 10000;
      border-size = 1;
      border-radius = 3;
      progress-color = "#212121ff";
    };
  };

  services.hypridle = {
    enable = true;
    settings = {
      listener =
        if isLaptop
        then [
          {
            timeout = 20 * 60;
            on-timeout = "systemctl suspend";
          }
          {
            timeout = 5 * 60;
            on-timeout = "hyprctl dispatch dpms off";
            on-resume = "hyprctl dispatch dpms on";
          }
        ]
        else [
          {
            timeout = 60 * 60;
            on-timeout = "hyprctl --batch 'dispatch dpms off DP-1 ; dispatch dpms off HDMI-A-1'";
            on-resume = "hyprctl --batch 'dispatch dpms on DP-1 ; dispatch dpms on HDMI-A-1'";
          }
        ];
    };
  };

  programs.hyprlock = {
    enable = true;
    extraConfig = ''
        general {
          hide_cursor = true
      }

      # BACKGROUND CONFIGURATION
      background {
          path = /home/suck/dotfiles/wallpaper.jpg
          blur_passes = 0
          blur_size = 1
      }

      # INPUT FIELD (PASSWORD)
      input-field {
          size = 600, 100
          position = 0, +200
          monitor =
          dots_center = true
          fade_on_empty = false
          font_color = rgba(100, 100, 100, 0.5)
          inner_color = rgba(255, 255, 255, 0.1)
          outer_color = rgba(255, 255, 255, 0.3)
          outline_thickness = 2
          placeholder_text = Password...
          shadow_passes = 4
          shadow_size = 8
          shadow_color = rgba(0, 0, 0, 0.3)

          # Glossy/glass effect settings
          rounding = 40

          # Authentication feedback
          check_color = rgba(34, 204, 136, 0.8)
          fail_color = rgba(204, 34, 34, 0.8)
          fail_text = <i>$FAIL <b>($ATTEMPTS)</b></i>

          # Additional glass effects
          capslock_color = rgba(255, 193, 7, 0.8)
          numlock_color = rgba(108, 117, 125, 0.8)
      }

      # TIME DISPLAY
      label {
          monitor =
          text = cmd[update:1000] echo "$(date +"%H:%M")"
          color = rgb(24, 25, 38)
          font_size = 55
          font_family = Fira Semibold
          position = 0, -150
          halign = center
          valign = top
      }

      # DATE DISPLAY
      label {
          monitor =
          text = cmd[update:43200000] echo "$(date +"%A, %d %B %Y")"
          color = rgb(24, 25, 38)
          font_size = 25
          font_family = Fira Semibold
          position = 0, -250
          halign = center
          valign = top
      }
    '';
  };

  services.clipse = {
    enable = true;
    package = clipse;
    allowDuplicates = false;
    historySize = 1000;
    systemdTarget = "hyprland-session.target";
    keyBindings = {
      choose = "esc,enter";
      down = "ctrl+d,j,d";
      up = "ctrl+u,k,u,t";
      remove = "D";
    };
  };

  # uwsm units live in ~/.nix-profile/share/systemd/user/ but systemd's user
  # manager can't load template-instantiated units from that path on non-NixOS.
  # Symlink them into ~/.config/systemd/user/ where systemd always looks.
  xdg.configFile = let
    uwsmUnits = [
      "app-graphical.slice"
      "background-graphical.slice"
      "fumon.service"
      "session-graphical.slice"
      "wayland-session-bindpid@.service"
      "wayland-session-pre@.target"
      "wayland-session-shutdown.target"
      "wayland-session-waitenv.service"
      "wayland-session-xdg-autostart@.target"
      "wayland-session@.target"
      "wayland-wm-app-daemon.service"
      "wayland-wm-env@.service"
      "wayland-wm@.service"
    ];
  in
    lib.mkIf isLaptop (builtins.listToAttrs (map (unit: {
          name = "systemd/user/${unit}";
          value.source = "${pkgs.uwsm}/share/systemd/user/${unit}";
        })
        uwsmUnits)
      // {
        "systemd/user/xdg-desktop-portal-hyprland.service".source = "${xdph}/share/systemd/user/xdg-desktop-portal-hyprland.service";
        "xdg-desktop-portal/hyprland-portals.conf".text = ''
          [preferred]
          default=hyprland;gtk
        '';
      }
      # Wrap XDPH with nixGLIntel so Nix mesa can find DRI drivers for DMA-BUF capture
      // mkExecOverride "xdg-desktop-portal-hyprland"
      "${nixGLIntel}/bin/nixGLIntel ${xdph}/libexec/xdg-desktop-portal-hyprland"
      # Use Nix xdg-desktop-portal binary so it discovers Nix-installed .portal files
      // mkExecOverride "xdg-desktop-portal"
      "${pkgs.xdg-desktop-portal}/libexec/xdg-desktop-portal"
      # Replace system PipeWire/WirePlumber with Nix versions to match client libraries
      // mkExecOverride "pipewire" "${pkgs.pipewire}/bin/pipewire"
      // mkExecOverride "pipewire-pulse" "${pkgs.pipewire}/bin/pipewire-pulse"
      // {
        # WirePlumber 0.5 needs XDG_DATA_DIRS to prefer its own config over
        # the system's incompatible 0.4 config at /usr/share/wireplumber/
        "systemd/user/wireplumber.service.d/override.conf".text = ''
          [Service]
          ExecStart=
          ExecStart=${pkgs.wireplumber}/bin/wireplumber
          Environment=XDG_DATA_DIRS=${pkgs.wireplumber}/share:%E:%h/.local/share:/usr/local/share:/usr/share
        '';
      });

  # D-Bus service files must live in ~/.local/share/dbus-1/services/ because the
  # session D-Bus daemon starts before Nix profile is sourced and its
  # XDG_DATA_DIRS doesn't include ~/.nix-profile/share.
  xdg.dataFile = lib.mkIf isLaptop {
    "dbus-1/services/org.freedesktop.impl.portal.desktop.hyprland.service".source = "${xdph}/share/dbus-1/services/org.freedesktop.impl.portal.desktop.hyprland.service";
    # Portal definition file must be discoverable for screen sharing to work
    "xdg-desktop-portal/portals/hyprland.portal".source = "${xdph}/share/xdg-desktop-portal/portals/hyprland.portal";
  };

  home.packages = with pkgs;
    [
      hyprpicker
      slurp
      wl-clip-persist
      wl-clipboard
      wl-screenrec
      grimblast
      ddcutil
      blueman
    ]
    ++ lib.optionals isLaptop [
      nixGLIntel
      xdg-desktop-portal
      xdg-desktop-portal-gtk
      pipewire
      wireplumber
    ];
}
