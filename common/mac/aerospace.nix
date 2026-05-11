{
  pkgs,
  lib,
  sec,
  ...
}: let
  aerospaceWs = pkgs.writeShellApplication {
    name = "aerospace-ws";
    runtimeInputs = [pkgs.aerospace];
    text = ''
      n=$1
      mode=''${2:-focus}
      mon=$(aerospace list-monitors --focused --format '%{monitor-name}')
      case "$mon" in
        *Built-in*) prefix=B ;;
        *)          prefix=E ;;
      esac
      case "$mode" in
        focus) aerospace workspace              "$prefix-$n" ;;
        move)  aerospace move-node-to-workspace "$prefix-$n" ;;
      esac
      aerospace move-mouse monitor-lazy-center
    '';
  };

  ws = "${aerospaceWs}/bin/aerospace-ws";

  micToggle = pkgs.writeShellScript "mic-toggle" ''
    current=$(/usr/bin/osascript -e 'input volume of (get volume settings)')
    if [ "$current" = "0" ]; then
      /usr/bin/osascript -e 'set volume input volume 100'
    else
      /usr/bin/osascript -e 'set volume input volume 0'
    fi
    ${pkgs.sketchybar}/bin/sketchybar           --trigger mic_toggle 2>/dev/null || true
    ${pkgs.sketchybarExt}/bin/sketchybar-ext    --trigger mic_toggle 2>/dev/null || true
  '';

  onWorkspaceChange = pkgs.writeShellScript "aerospace-ws-changed" ''
    ${pkgs.sketchybar}/bin/sketchybar           --trigger aerospace_workspace_change FOCUSED_WORKSPACE="$AEROSPACE_FOCUSED_WORKSPACE" 2>/dev/null || true
    ${pkgs.sketchybarExt}/bin/sketchybar-ext    --trigger aerospace_workspace_change FOCUSED_WORKSPACE="$AEROSPACE_FOCUSED_WORKSPACE" 2>/dev/null || true
  '';

  onFullscreenChange = pkgs.writeShellScript "aerospace-fs-changed" ''
    ${pkgs.sketchybar}/bin/sketchybar           --trigger fullscreen_changed 2>/dev/null || true
    ${pkgs.sketchybarExt}/bin/sketchybar-ext    --trigger fullscreen_changed 2>/dev/null || true
  '';

  openHmApp = app: ''exec-and-forget open -na "${sec.mac.homeDir}/Applications/Home Manager Apps/${app}.app"'';

  numbers = lib.range 1 9;
  letters = ["x" "c" "v" "s" "d" "f" "w" "e" "r"];

  numberBinds = lib.listToAttrs (lib.concatMap (n: let
      s = toString n;
      move = mod: {
        name = "cmd-${mod}-${s}";
        value = "exec-and-forget ${ws} ${s} move";
      };
    in [
      {
        name = "cmd-${s}";
        value = "exec-and-forget ${ws} ${s} focus";
      }
      (move "shift")
      (move "ctrl")
    ])
    numbers);

  letterBinds = lib.listToAttrs (lib.imap1 (i: k: {
      name = "cmd-ctrl-${k}";
      value = "exec-and-forget ${ws} ${toString i} focus";
    })
    letters);

  mkAssignment = prefix: target:
    lib.genAttrs
    (map (n: "${prefix}-${toString n}") numbers)
    (_: target);

  modMask = {
    shift = 131072; # 1 << 17
    control = 262144; # 1 << 18
    option = 524288; # 1 << 19
    command = 1048576; # 1 << 20
  };

  hotkey = ascii: vkey: mods: {
    enabled = 1;
    value = {
      # [ascii, virtual-key-code, modifier-mask].
      parameters = [
        ascii
        vkey
        (lib.foldl' (a: m: a + modMask.${m}) 0 mods)
      ];
      type = "standard";
    };
  };

  enabledHotkeys = {
    "64" = hotkey 112 35 ["command"]; # Spotlight on cmd+p.
    "60" = hotkey 32 49 ["control"]; # Cycle keyboard layouts on ctrl+space.
  };

  symbolicHotkeys =
    lib.genAttrs (map toString (lib.range 1 235)) (_: {enabled = 0;})
    // enabledHotkeys;
in {
  system.defaults.CustomUserPreferences = {
    NSGlobalDomain.NSAutomaticWindowAnimationsEnabled = false;
    "com.apple.spaces".span-displays = true;
    "com.apple.symbolichotkeys".AppleSymbolicHotKeys = symbolicHotkeys;
  };

  environment.systemPackages = [pkgs.autoraise aerospaceWs];

  launchd.user.agents.autoraise = {
    serviceConfig.ProgramArguments = [
      "${pkgs.autoraise}/bin/AutoRaise"
      "-disableKey"
      "disabled"
    ];
    serviceConfig.RunAtLoad = true;
    serviceConfig.KeepAlive = true;
  };

  services.aerospace = {
    enable = true;
    settings = {
      gaps = {
        outer.left = 0;
        outer.right = [
          {monitor."^Built-in" = 0;}
          32 # reserved space for sketchybar
        ];
        outer.top = 0;
        outer.bottom = 0;
        inner.horizontal = 0;
        inner.vertical = 0;
      };

      default-root-container-layout = "tiles";
      default-root-container-orientation = "auto";

      # for direction preselect on cmd-c/v
      enable-normalization-opposite-orientation-for-nested-containers = false;
      enable-normalization-flatten-containers = false;

      on-window-detected = [
        {
          "if".app-id = "org.alacritty.clipse";
          run = ["layout floating"];
        }
        {
          "if".app-id = "com.apple.systempreferences";
          run = ["layout tiling"];
        }
      ];

      exec-on-workspace-change = ["${onWorkspaceChange}"];

      workspace-to-monitor-force-assignment =
        (mkAssignment "B" "^Built-in")
        // (mkAssignment "E" ["secondary" "main"]);

      mode.main.binding =
        {
          cmd-enter = openHmApp "Alacritty";
          cmd-b = openHmApp "Firefox";
          cmd-shift-b = "exec-and-forget open -a /Applications/Safari.app";
          cmd-esc = ''${openHmApp "Alacritty-clipse"} --args -e ${pkgs.clipse}/bin/clipse'';
          cmd-f = ["fullscreen" "exec-and-forget ${onFullscreenChange}"];
          cmd-space = "layout floating tiling";

          f13 = "exec-and-forget screencapture -c -w";
          shift-f13 = "exec-and-forget screencapture -c -i";
          f14 = "exec-and-forget screencapture -w ~/screenshots/Screenshot.png";
          shift-f14 = "exec-and-forget screencapture -i ~/screenshots/Screenshot.png";
          f15 = "exec-and-forget ${micToggle}";

          cmd-h = "focus left";
          cmd-j = "focus down";
          cmd-k = "focus up";
          cmd-l = "focus right";

          cmd-shift-h = "move left";
          cmd-shift-j = "move down";
          cmd-shift-k = "move up";
          cmd-shift-l = "move right";

          # Can't bind to cmd-c/v because that's reserved by macos
          # So bind to cmd-alt-c/v and remap cmd-c/v -> cmd-alt-c/v with karabiner
          cmd-alt-c = "split horizontal";
          cmd-alt-v = "split vertical";

          cmd-ctrl-h = "resize width -150";
          cmd-ctrl-l = "resize width +150";
          cmd-ctrl-j = "resize height -100";
          cmd-ctrl-k = "resize height +100";

          cmd-i = "balance-sizes";

          cmd-comma = ["focus-monitor --wrap-around next" "move-mouse monitor-lazy-center"];
          cmd-shift-comma = ["move-node-to-monitor --wrap-around next" "move-mouse monitor-lazy-center"];

          cmd-tab = "focus-back-and-forth";
        }
        // numberBinds
        // letterBinds;
    };
  };
}
