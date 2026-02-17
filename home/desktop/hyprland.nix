{
  lib,
  pkgs,
  pkgs-unstable,
  config,
  nixgl,
  ...
}: let
  isLaptop = config.custom.workLaptop.enable;

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
      then config.lib.nixGL.wrap pkgs-unstable.hyprland
      else null;
    portalPackage = null;

    plugins = with pkgs-unstable.hyprlandPlugins; [
      hyprsplit
      hy3
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
          "SUPER, B, exec, ${uwsm} firefox"
          "SUPER SHIFT, B, exec, ${uwsm} google-chrome-stable --enable-features=VaapiVideoDecodeLinuxGL --use-gl=angle --use-angle=gl --ozone-platform=wayland"
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
          monitor=,highrr,auto-center-up,1
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
            timeout = 10 * 60;
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
      uwsmUnits));

  home.packages = with pkgs; [
    (lib.mkIf isLaptop pkgs.nixgl.nixGLIntel)

    hyprpicker
    slurp
    wl-clip-persist
    wl-clipboard
    wl-screenrec
    grimblast
    ddcutil
    blueman
  ];
}
