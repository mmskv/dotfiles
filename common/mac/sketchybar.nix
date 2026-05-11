{
  pkgs,
  lib,
  sec,
  ...
}: let
  colorBg = "0xff141414";
  colorFg = "0xffDCD7BA";
  colorActive = "0xffEA803F";
  colorBorder = "0xff212121";
  colorErr = "0xffF0C674";

  pm = pkgs.callPackage ../pm {};

  mkScripts = isExt: bin: let
    SB = bin;
  in {
    workspace = pkgs.writeShellScript "sb-workspace-${baseNameOf bin}" ''
      focused=''${FOCUSED_WORKSPACE:-$(${pkgs.aerospace}/bin/aerospace list-workspaces --focused 2>/dev/null)}
      ws=''${NAME#space.}
      digit=''${ws##*-}

      fs=$(${pkgs.aerospace}/bin/aerospace list-windows --workspace "$ws" --format '%{window-is-fullscreen}' 2>/dev/null)
      if [ -z "$fs" ]; then
        count=0; has_fs=0
      else
        count=$(printf '%s\n' "$fs" | ${pkgs.coreutils}/bin/wc -l | ${pkgs.coreutils}/bin/tr -d ' ')
        has_fs=$(printf '%s\n' "$fs" | grep -c '^true$')
      fi

      if [ "$has_fs" -gt 0 ]; then
        ${SB} --set "$NAME" label="$digit" label.color=${colorBg} \
              background.drawing=on background.color=${colorActive} \
              background.height=20 background.corner_radius=2
      elif [ "$ws" = "$focused" ]; then
        ${SB} --set "$NAME" label="$digit" label.color=${colorActive} \
              background.drawing=off
      elif [ "$count" = "0" ]; then
        ${SB} --set "$NAME" label="$digit" label.color=${colorBorder} \
              background.drawing=off
      else
        ${SB} --set "$NAME" label="$digit" label.color=${colorFg} \
              background.drawing=off
      fi
    '';

    vpn = pkgs.writeShellScript "sb-vpn-${baseNameOf bin}" ''
      if output=$(${pkgs.dogdns}/bin/dog o-o.myaddr.l.google.com --tls @dns.google txt -1 2>/dev/null); then
        if echo "$output" | grep -q ${sec.mysubnet}; then
          ${SB} --set "$NAME" label=V label.color=${colorBorder}
        else
          ${SB} --set "$NAME" label=V label.color=${colorActive}
        fi
      else
        ${SB} --set "$NAME" label=O label.color=${colorErr}
      fi
    '';

    mic = pkgs.writeShellScript "sb-mic-${baseNameOf bin}" ''
      vol=$(/usr/bin/osascript -e 'input volume of (get volume settings)')
      if [ "$vol" = "0" ]; then
        ${SB} --set "$NAME" label=M label.color=${colorActive}
      else
        ${SB} --set "$NAME" label=M label.color=${colorBorder}
      fi
    '';

    # White (DCD7BA) above 50%, quadratic ease to red (FF0000) toward 0%.
    battery = pkgs.writeShellScript "sb-battery-${baseNameOf bin}" ''
      batt=$(/usr/bin/pmset -g batt 2>/dev/null)
      case "$batt" in
        *InternalBattery*) ;;
        *) ${SB} --set "$NAME" drawing=off; exit 0 ;;
      esac
      cap=0
      [[ "$batt" =~ ([0-9]+)% ]] && cap=''${BASH_REMATCH[1]}
      [ "$cap" -gt 100 ] && cap=100
      [ "$cap" -lt 0 ] && cap=0
      threshold=50
      if [ "$cap" -ge "$threshold" ]; then
        r=220; g=215; b=186
      else
        diff=$(( threshold - cap ))
        t2=$(( diff * diff * 1000 / (threshold * threshold) ))
        r=$(( 220 + t2 *  35 / 1000 ))
        g=$(( 215 - t2 * 215 / 1000 ))
        b=$(( 186 - t2 * 186 / 1000 ))
      fi
      color=$(printf '0xff%02X%02X%02X' "$r" "$g" "$b")
      case "$batt" in
        *"; charging"*) letter=C ;;
        *)              letter=B ;;
      esac
      ${SB} --set "$NAME" drawing=on label="$letter" label.color="$color"
    '';

    keyboard = pkgs.writeShellScript "sb-keyboard-${baseNameOf bin}" ''
      name=$(/usr/bin/defaults read com.apple.HIToolbox AppleSelectedInputSources 2>/dev/null \
             | /usr/bin/awk -F' = ' '/KeyboardLayout Name/{gsub(/[";]/, "", $2); print $2; exit}')
      case "$name" in
        Russian*) label=R; padl=${
        if isExt
        then "4"
        else "4"
      }; padr=${
        if isExt
        then "4"
        else "4"
      } ;;
        *)        label=E; padl=${
        if isExt
        then "3"
        else "4"
      }; padr=${
        if isExt
        then "5"
        else "4"
      } ;;
      esac
      ${SB} --set "$NAME" label="$label" label.padding_left=$padl label.padding_right=$padr
    '';

    clock = fmt:
      pkgs.writeShellScript "sb-clock-${baseNameOf bin}-${builtins.hashString "sha1" fmt}" ''
        raw=$(${pkgs.coreutils}/bin/date '+${fmt}')
        ${SB} --set "$NAME" label="''${raw//  / }"
      '';

    pomodoro = pkgs.writeShellScript "sb-pomodoro-${baseNameOf bin}" ''
      out=$(${pm}/bin/pm tick)
      if [ -z "$out" ]; then
        ${SB} --set "$NAME" drawing=off
      else
        case "$out" in
          W*) ${SB} --set "$NAME" drawing=on label="$out" label.color=${colorActive} ;;
          *)  ${SB} --set "$NAME" drawing=on label="R" label.color=${colorBorder} ;;
        esac
      fi
    '';
  };

  main = mkScripts false "sketchybar";
  ext = mkScripts true "${pkgs.sketchybarExt}/bin/sketchybar-ext";

  mkBarBody = {
    bin,
    position,
    display,
    height,
    barPaddingLeft,
    barPaddingRight,
    fontSize,
    wsPrefix,
    wsPadding,
    scripts,
  }: ''
    ${bin} --bar                                                \
        position=${position}                                    \
        display=${display}                                      \
        height=${toString height}                               \
        padding_left=${toString barPaddingLeft}                 \
        padding_right=${toString barPaddingRight}               \
        color=${colorBg}                                        \
        border_width=0

    ${bin} --default                                            \
        updates=when_shown                                      \
        label.font="FiraMono Nerd Font:Bold:${fontSize}"        \
        label.color=${colorFg}                                  \
        label.padding_left=4                                    \
        label.padding_right=4                                   \
        padding_left=4                                          \
        padding_right=4                                         \
        background.drawing=off

    ${bin} --add event aerospace_workspace_change
    ${bin} --add event fullscreen_changed
    ${bin} --add event mic_toggle

    for i in 1 2 3 4 5 6 7 8 9; do
      ws="${wsPrefix}-$i"
      ${bin} --add item space.$ws left                          \
             --set space.$ws                                    \
                 padding_left=${toString wsPadding}             \
                 padding_right=${toString wsPadding}            \
                 label="$i"                                     \
                 click_script="${pkgs.aerospace}/bin/aerospace workspace $ws" \
                 script="${scripts.workspace}"                  \
             --subscribe space.$ws aerospace_workspace_change fullscreen_changed
    done
  '';

  # ── external bar config (vertical, on right of secondary displays) ──
  # sketchybar's vertical mode is undocumented:
  #   - bar.padding_left / padding_right map to the bar's TOP and BOTTOM
  #     flow-axis margins respectively (not cross-axis as the names would suggest).
  #   - Cross-axis label centring needs explicit label.width=32 +
  #     label.align=center; "automatic centring" of items doesn't
  #     reliably keep glyphs in the same column.
  extBarConfig = pkgs.writeShellScript "sketchybarrc-ext" ''
    PATH=${lib.makeBinPath [pkgs.sketchybarExt pkgs.sketchybar pkgs.coreutils pkgs.jq]}:$PATH

    ${mkBarBody {
      bin = "sketchybar-ext";
      position = "right";
      display = "2,3,4";
      height = 32;
      barPaddingLeft = 6;
      barPaddingRight = 8;
      fontSize = "15.0";
      wsPrefix = "E";
      wsPadding = 10;
      scripts = ext;
    }}

    sketchybar-ext --default                                          \
        padding_left=0                                                \
        padding_right=16                                              \
        label.width=32                                                \
        label.align=center
    sketchybar-ext                                                    \
      --add item clock_m right                                        \
      --set  clock_m update_freq=30 script="${ext.clock "%M"}"        \
                     padding_right=0                                  \
      --add item clock_h right                                        \
      --set  clock_h update_freq=30 script="${ext.clock "%H"}"        \
                     padding_right=4                                  \
      --add item kbd right                                            \
      --set  kbd update_freq=5 script="${ext.keyboard}"               \
      --add item battery right                                        \
      --set  battery update_freq=30 script="${ext.battery}"           \
      --add item mic right                                            \
      --set  mic update_freq=30 script="${ext.mic}"                   \
                 label.color=${colorBorder}                           \
      --subscribe mic mic_toggle                                      \
      --add item vpn right                                            \
      --set  vpn update_freq=10 script="${ext.vpn}"                   \
                 label.color=${colorBorder}                           \
      --add item pomodoro right                                       \
      --set  pomodoro update_freq=10 updates=on                       \
                      script="${ext.pomodoro}"                        \
                      click_script="${pm}/bin/pm toggle"              \
                      drawing=off

    sketchybar-ext --update
  '';
in {
  # instance for external monitor
  nixpkgs.overlays = [
    (final: prev: {
      sketchybarExt = prev.runCommand "sketchybar-ext" {} ''
        mkdir -p $out/bin
        ln -s ${prev.sketchybar}/bin/sketchybar $out/bin/sketchybar-ext
      '';
    })
  ];

  fonts.packages = with pkgs; [
    nerd-fonts.fira-mono
  ];

  environment.systemPackages = with pkgs; [
    mos
    choose-gui
    sketchybarExt
    pm
  ];

  services.sketchybar = {
    enable = true;
    extraPackages = with pkgs; [coreutils jq aerospace dogdns];
    config = ''
      #!/usr/bin/env bash

      ${mkBarBody {
        bin = "sketchybar";
        position = "top";
        display = "main";
        height = 38;
        barPaddingLeft = 12;
        barPaddingRight = 12;
        fontSize = "13.0";
        wsPrefix = "B";
        wsPadding = 2;
        scripts = main;
      }}

      sketchybar                                                  \
        --add item clock_time right                               \
        --set  clock_time update_freq=30 script="${main.clock "%H:%M"}" \
        --add item clock_date right                               \
        --set  clock_date update_freq=30 script="${main.clock "%a %e %b"}" \
                          padding_left=8                          \
        --add item kbd right                                      \
        --set  kbd update_freq=5 script="${main.keyboard}"        \
                   padding_left=8                                 \
        --add item battery right                                  \
        --set  battery update_freq=30 script="${main.battery}"    \
                       padding_left=8                             \
        --add item mic right                                      \
        --set  mic update_freq=30 script="${main.mic}"            \
                   label.color=${colorBorder}                     \
                   padding_left=8                                 \
        --subscribe mic mic_toggle                                \
        --add item vpn right                                      \
        --set  vpn update_freq=10 script="${main.vpn}"            \
                   label.color=${colorBorder}                     \
        --add item pomodoro right                                 \
        --set  pomodoro update_freq=10 updates=on                 \
                        script="${main.pomodoro}"                 \
                        click_script="${pm}/bin/pm toggle"        \
                        padding_left=8                            \
                        drawing=off

      sketchybar --update
    '';
  };

  launchd.user.agents.sketchybar-ext = {
    serviceConfig = {
      ProgramArguments = [
        "${pkgs.sketchybarExt}/bin/sketchybar-ext"
        "--config"
        "${extBarConfig}"
      ];
      KeepAlive = true;
      RunAtLoad = true;
    };
    environment.PATH = lib.concatStringsSep ":" (
      [(lib.makeBinPath (with pkgs; [sketchybarExt sketchybar coreutils jq aerospace dogdns]))]
      ++ [
        "/run/current-system/sw/bin"
        "/nix/var/nix/profiles/default/bin"
        "/usr/local/bin"
        "/usr/bin"
        "/bin"
        "/usr/sbin"
        "/sbin"
      ]
    );
  };
}
