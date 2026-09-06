{
  desktopTheme,
  lib,
  pkgs,
  pkgs-unstable,
  ...
}: let
  inherit (desktopTheme) colors cursor uiScale;
  logicalPixels = pixels: builtins.floor ((pixels / uiScale) + 0.5);
  uiScaleText = builtins.toJSON uiScale;
  sideMonitorX = 0 - logicalPixels 1440;
  sideMonitorY = 0 - logicalPixels 640;
  screenshot_name = ''$HOME"/screenshots/Screenshot $(date +%F) at $(date +%T).png"'';
in {
  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;
    systemd.enable = true;
    configType = "hyprlang";

    package = null;
    portalPackage = null;

    plugins = [
      (pkgs.hyprlandPlugins.hyprsplit.overrideAttrs (_: {
        version = "unstable-2026-05-22";
        src = pkgs.fetchFromGitHub {
          owner = "shezdy";
          repo = "hyprsplit";
          rev = "0fc01e7930625ecb3e069f5dc8e1d61eab929f3b";
          hash = "sha256-XpwuFhwnfwPbzImZeUWWns///UEpoKNkpl1hN90C3Ag=";
        };
      }))
      pkgs.hyprlandPlugins.hy3
    ];

    settings = {
      exec-once = [
        "hyprctl setcursor ${cursor.name} ${toString cursor.size}"
        "uwsm app -- wl-clip-persist --clipboard both"
        # Calino is on DP-3's first workspace; its title is generic at window creation.
        "[monitor DP-3; workspace 10 silent] uwsm app -- firefox --new-window https://cal.int.niggalink.space:8443/week"
      ];

      input = {
        kb_layout = "uscustom,rucustom";
        kb_options = "grp:ctrl_space_toggle,caps:escape";
        repeat_delay = 380;
        repeat_rate = 35;
      };

      cursor.inactive_timeout = 3;

      general = {
        layout = "hy3";
        gaps_in = 0;
        gaps_out = 0;
        "col.active_border" = "rgb(${colors.activeBorder}) rgb(${colors.accentMuted}) 45deg";
        "col.inactive_border" = "0xff${colors.border}";
      };

      group = {
        "col.border_active" = "rgb(${colors.activeBorder})";
        "col.border_inactive" = "0xff${colors.border}";
      };

      misc = {
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
        enable_anr_dialog = false;
        size_limits_tiled = true;
        animate_manual_resizes = true;
        enable_swallow = true;
        swallow_regex = "^(Alacritty)$";
        mouse_move_enables_dpms = true;
        key_press_enables_dpms = true;
      };

      animations = {
        enabled = true;

        bezier = [
          "fluent_decel, 0, 0.2, 0.4, 1"
          "easeOutCirc, 0, 0.55, 0.45, 1"
          "easeOutCubic, 0.33, 1, 0.68, 1"
          "fade_curve, 0, 0.55, 0.45, 1"
        ];

        animation = [
          # name, enable, speed, curve, style

          "windowsIn,   0" # window open
          "windowsOut,  0" # window close.
          "windowsMove, 1, 0.7, fluent_decel, slide" # everything in between: moving, dragging, resizing.

          "fade,        0"
          "border,      1, 1.7, easeOutCirc" # for animating the border's color switch speed
          "borderangle, 1, 10,  fluent_decel, once" # for animating the border's gradient angle - styles: once (default), loop
          "workspaces,  1, 3.5, easeOutCubic, slidevert"
        ];
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
          "SUPER, Return, exec, uwsm app -- alacritty"
          "SUPER, B, exec, uwsm app -- firefox"
          "SUPER SHIFT, B, exec, uwsm app -- google-chrome-stable --enable-features=VaapiVideoDecodeLinuxGL --use-gl=angle --use-angle=gl --ozone-platform=wayland"
          "SUPER, Q, killactive,"
          "SUPER, F, fullscreen, 1"
          "SUPER, Space, togglefloating"
          "SUPER, P, exec, uwsm app -- fuzzel"
          "SUPER, P, exec, uwsm app -- fuzzel"
          "SUPER, Escape, exec, uwsm app -- alacritty --class clipse -e 'clipse'"

          "SUPER, comma, focusmonitor, +1"
          "SUPER SHIFT, comma, movewindow, mon:+1"

          "SUPER, X, split:swapactiveworkspaces, current +1"

          "SUPER, mouse_down, workspace, -1"
          "SUPER, mouse_up, workspace, +1"
          "SUPER, mouse_left, focusmonitor, -1"
          "SUPER, mouse_right, focusmonitor, +1"

          # hillside binds
          ",Print, exec, uwsm app -- grimblast copy active"
          ",XF86Screensaver, exec, uwsm app -- grimblast save active ${screenshot_name}"
          "SHIFT ,Print, exec, uwsm app -- grimblast copy area"
          "SHIFT ,XF86Screensaver, exec, uwsm app -- grimblast save area ${screenshot_name}"

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
          ",XF86AudioPlay,exec, playerctl play-pause"
          ",XF86AudioNext,exec, playerctl next"
          ",XF86AudioPrev,exec, playerctl previous"
        ]
        ++ (map (i: "SUPER, ${toString i}, split:workspace, ${toString i}") (lib.range 1 9))
        ++ (map (i: "SUPER CTRL, ${toString i}, split:movetoworkspacesilent, ${toString i}") (lib.range 1 9))
        # map to hillside numpad
        ++ (lib.imap1 (i: key: "SUPER CTRL, ${key}, split:workspace, ${toString i}") ["x" "c" "v" "s" "d" "f" "w" "e" "r"]);

      # binds that repeat when held
      binde = [
        ",XF86AudioRaiseVolume,exec, pamixer -u -i 5"
        ",XF86AudioLowerVolume,exec, pamixer -u -d 5"

        "SUPER CTRL, H, resizeactive, -150 0"
        "SUPER CTRL, J, resizeactive, 0 -100"
        "SUPER CTRL, K, resizeactive, 0 100"
        "SUPER CTRL, L, resizeactive, 150 0"
      ];

      # mouse binding
      bindm = [
        "SUPER, mouse:272, movewindow"
        "SUPER, mouse:273, resizewindow"
      ];

      # windowrulev2
      windowrule =
        [
          "match:class ^tauonmb$, workspace 14"
          "match:class ^org.telegram.desktop$, workspace 10"
          "match:class ^firefox$, idle_inhibit fullscreen"
          "match:class ^mpv$, idle_inhibit focus"

          "match:title ^Enter name of file to save, size 500 700"

          "match:class ^clipse$, float on, border_size 1, size 800 700, opacity 0.8, rounding 10"

          "match:class ^org.telegram.desktop$, match:title ^Media viewer$, fullscreen on"

          "match:workspace w[t1], border_size 0"
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

    extraConfig = ''
      monitor=DP-1,5120x2160@165.00,0x0,${uiScaleText}
      monitor=DP-2,preferred,0x0,${uiScaleText}
      monitor=DP-3,3440x1440@144.00,${toString sideMonitorX}x${toString sideMonitorY},${uiScaleText},transform,1

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
      ipc = false;
      # hyprpaper 0.8+ renders Hyprland's splash text itself and defaults to on
      splash = false;
      # hyprpaper 0.8+ config format: repeated wallpaper {} blocks, no preload
      wallpaper =
        (map (m: {
          monitor = m;
          path = "${../../wallpaper.jpg}";
        }) ["DP-1" "DP-2"])
        ++ (map (m: {
          monitor = m;
          path = "${../../wallpaper2.jpg}";
        }) ["DP-3"]);
    };
  };

  services.mako = {
    enable = true;
    settings = {
      font = desktopTheme.fonts.ui;
      background-color = "#${colors.background}ff";
      text-color = "#${colors.foreground}ff";
      border-color = "#${colors.accent}ff";
      default-timeout = 10000;
      border-size = 1;
      border-radius = 3;
    };
  };

  services.hypridle = {
    enable = true;
    package = pkgs-unstable.hypridle;
    settings = {
      listener = [
        {
          timeout = 10 * 60;
          # wlopm (wlr-output-power-management), NOT `hyprctl dispatch dpms`:
          # the native dpms-on path fails to re-enable the outputs on wake on
          # this NVIDIA setup and leaves the monitors stuck black. wlopm's
          # re-enable path wakes reliably. The intermittent wake-time crash is
          # handled downstream (hyprsunset Restart=on-failure + Hyprland patch).
          on-timeout = "${pkgs.wlopm}/bin/wlopm --off '*'";
          on-resume = "${pkgs.wlopm}/bin/wlopm --on '*'";
        }
      ];
    };
  };

  services.clipse = {
    enable = true;
    package = pkgs-unstable.clipse;
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

  home.packages = with pkgs; [
    hyprpicker
    slurp
    wl-clip-persist
    wl-clipboard
    wl-screenrec
    grimblast
    ddcutil
  ];
}
