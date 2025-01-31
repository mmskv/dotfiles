{pkgs, ...}: let
  screenshot_name = ''$HOME"/screenshots/Screenshot $(date +%F) at $(date +%T).png"'';
in {
  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;
    systemd.enable = true;

    plugins = with pkgs.hyprlandPlugins; [
      hyprsplit
      hyprexpo
    ];

    settings = {
      exec-once = [
        "hyprctl setcursor phinger-cursors-dark 24"
        "wl-clip-persist --clipboard both"
      ];

      input = {
        kb_layout = "us,ru";
        kb_options = "grp:ctrl_space_toggle,caps:escape";
        repeat_delay = 380;
        repeat_rate = 35;
      };

      cursor.inactive_timeout = 3;

      general = {
        layout = "master";
        gaps_in = 0;
        gaps_out = 0;
        "col.active_border" = "rgb(4b5366) rgb(9c7446) 45deg";
        "col.inactive_border" = "0xff212121";
        border_part_of_window = false;
        no_border_on_floating = false;
      };

      master = {
        orientation = "right";
      };

      misc = {
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
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

          "windowsIn,   0, 4, easeOutCubic,  popin 20%" # window open
          "windowsOut,  0, 4, fluent_decel,  popin 80%" # window close.
          "windowsMove, 1, 2, fluent_decel, slide" # everything in between, moving, dragging, resizing.

          "fadeIn,      0, 3,   fade_curve" # fade in (open) -> layers and windows
          "fadeOut,     0, 3,   fade_curve" # fade out (close) -> layers and windows
          "fadeSwitch,  0, 1,   easeOutCirc" # fade on changing activewindow and its opacity
          "fadeShadow,  0, 10,  easeOutCirc" # fade on changing activewindow for shadows
          "fadeDim,     0, 4,   fluent_decel" # the easing of the dimming of inactive windows
          "border,      0, 1.7, easeOutCirc" # for animating the border's color switch speed
          "borderangle, 1, 10,  fluent_decel, once" # for animating the border's gradient angle - styles: once (default), loop
          "workspaces,  1, 3.5,   easeOutCubic, slidevert"
          "specialWorkspace,  1, 2,  easeOutCirc, slidefadevert -50%"
        ];
      };

      decoration = {
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

      bind = [
        # keybindings
        "SUPER, Return, exec, alacritty"
        "SUPER, I, exec, telegram-desktop && hyprctl dispatch focuswindow org.telegram.desktop"
        "SUPER, B, exec, firefox"
        "SUPER SHIFT, B, exec, google-chrome-stable --enable-features=VaapiVideoDecodeLinuxGL --use-gl=angle --use-angle=gl --ozone-platform=wayland"
        "SUPER, Q, killactive,"
        "SUPER, F, fullscreen, 1"
        "SUPER, Space, togglefloating"
        "SUPER, P, exec, fuzzel"

        ",Print, exec, screenshot --copy"
        "SUPER, Print, exec, screenshot --save"
        "SUPER SHIFT, Print, exec, screenshot --swappy"

        "SUPER, H, splitratio, +0.1"
        "SUPER, J, layoutmsg, cyclenext"
        "SUPER, K, layoutmsg, cycleprev"
        "SUPER, L, splitratio, -0.1"

        "SUPER SHIFT, Return, layoutmsg, swapwithmaster"
        "SUPER, M, layoutmsg, orientationcycle left right center"
        "SUPER, comma, focusmonitor, +1"
        "SUPER SHIFT, comma, movewindow, mon:+1"

        "SUPER, X, split:swapactiveworkspaces, current +1"
        "SUPER, SUPER_R, hyprexpo:expo, toggle"

        "SUPER, mouse_down, workspace, -1"
        "SUPER, mouse_up, workspace, +1"
        "SUPER, mouse_left, focusmonitor, -1"
        "SUPER, mouse_right, focusmonitor, +1"

        ",XF86LaunchA, exec, grimblast copy active"
        ",XF86LaunchB, exec, grimblast save active ${screenshot_name}"

        "SHIFT ,XF86LaunchA, exec, grimblast copy area"
        "SHIFT ,XF86LaunchB, exec, grimblast save area ${screenshot_name}"

        "SUPER, apostrophe, togglespecialworkspace"

        # switch workspace
        "SUPER, 1, split:workspace, 1"
        "SUPER, 2, split:workspace, 2"
        "SUPER, 3, split:workspace, 3"
        "SUPER, 4, split:workspace, 4"
        "SUPER, 5, split:workspace, 5"
        "SUPER, 6, split:workspace, 6"
        "SUPER, 7, split:workspace, 7"
        "SUPER, 8, split:workspace, 8"
        "SUPER, 9, split:workspace, 9"

        # same as above, but switch to the workspace
        "SUPER SHIFT, 1, split:movetoworkspacesilent, 1"
        "SUPER SHIFT, 2, split:movetoworkspacesilent, 2"
        "SUPER SHIFT, 3, split:movetoworkspacesilent, 3"
        "SUPER SHIFT, 4, split:movetoworkspacesilent, 4"
        "SUPER SHIFT, 5, split:movetoworkspacesilent, 5"
        "SUPER SHIFT, 6, split:movetoworkspacesilent, 6"
        "SUPER SHIFT, 7, split:movetoworkspacesilent, 7"
        "SUPER SHIFT, 8, split:movetoworkspacesilent, 8"
        "SUPER SHIFT, 9, split:movetoworkspacesilent, 9"

        ",XF86AudioMute,exec, pamixer -t"
        ",XF86AudioPlay,exec, playerctl play-pause"
        ",XF86AudioNext,exec, playerctl next"
        ",XF86AudioPrev,exec, playerctl previous"
      ];

      # binds that repeat when held
      binde = [
        ",XF86AudioRaiseVolume,exec, pamixer -u -i 5"
        ",XF86AudioLowerVolume,exec, pamixer -u -d 5"
      ];

      # mouse binding
      bindm = [
        "SUPER, mouse:272, movewindow"
        "SUPER, mouse:273, resizewindow"
      ];

      workspace = [
        "s[true], on-created-empty:hyprctl dispatch -- exec [workspace special] alacritty --class alacritty-float -o window.opacity=0.5 -e tmux new-session -A -s special"
      ];

      # windowrule
      windowrule = [
        "float,mpv"
        "idleinhibit focus,mpv"
        "float,title:^(Volume Control)$"
        "float,title:^(Firefox — Sharing Indicator)$"
        "move 0 0,title:^(Firefox — Sharing Indicator)$"
        "size 700 450,title:^(Volume Control)$"
      ];

      # windowrulev2
      windowrulev2 = [
        "noblur,floating:0"

        "float, title:^(Picture-in-Picture)$"
        "opacity 1.0 override 1.0 override, title:^(Picture-in-Picture)$"
        "pin, title:^(Picture-in-Picture)$"
        "idleinhibit focus, class:^(mpv)$"
        "idleinhibit fullscreen, class:^(firefox)$"
        "float,class:^(pavucontrol)$"
        "float,class:^(file_progress)$"
        "float,class:^(confirm)$"
        "float,class:^(dialog)$"
        "float,class:^(download)$"
        "float,class:^(notification)$"
        "float,class:^(error)$"
        "float,class:^(confirmreset)$"
        "float,title:^(Open File)$"
        "float,title:^(File Upload)$"
        "float,title:^(branchdialog)$"
        "float,title:^(Confirm to replace files)$"
        "float,title:^(File Operation Progress)$"
        "float,class:^(org.telegram.desktop)$,title:^(Media viewer)$"

        "float,class:alacritty-float"
        "bordersize 0,class:alacritty-float"
        "animation slide bottom,class:alacritty-float"
        "move onscreen 20% 0,class:alacritty-float"
        "size 60% 30%,class:alacritty-float"

        "opacity 0.0 override,class:^(xwaylandvideobridge)$"
        "noanim,class:^(xwaylandvideobridge)$"
        "noinitialfocus,class:^(xwaylandvideobridge)$"
        "maxsize 1 1,class:^(xwaylandvideobridge)$"

        "bordersize 0, floating:0, onworkspace:w[tv1]" # no border when only
      ];
    };

    extraConfig = ''
      monitor=DP-1,3440x1440@144,0x0,1
      monitor=HDMI-A-1,1920x1080@75,3440x0,1

      xwayland {
        force_zero_scaling = true
      }

      plugin {
        hyprsplit {
          persistent_workspaces = true
          num_workspaces = 9
        }

        hyprfocus {
          enabled = yes
          animate_floating = no
          animate_workspacechange = no
          focus_animation = flash

          bezier = realsmooth, 0.28,0.29,.69,1.08

          flash {
            flash_opacity = 0.95
            in_bezier = realsmooth
            in_speed = 1
            out_bezier = realsmooth
            out_speed = 3
          }
       }
      }
    '';
  };

  services.hyprpaper = {
    enable = true;
    settings = {
      ipc = false;
      preload = ["${../wallpaper.jpg}"];
      wallpaper = [",${../wallpaper.jpg}"];
    };
  };

  services.mako = {
    enable = true;
    font = "Fira Mono";
    backgroundColor = "#141414ff";
    textColor = "#C5C8C6ff";
    borderColor = "#EA803Fff";
    borderSize = 1;
    borderRadius = 3;
  };

  home.packages = with pkgs; [
    hyprpicker
    slurp
    wl-clip-persist
    wl-clipboard
    wl-screenrec
    grimblast
  ];
}
