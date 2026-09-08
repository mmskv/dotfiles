{
  lib,
  pkgs,
  sec,
  ...
}: let
  hosts = sec.mouse;
  mxswitch = pkgs.callPackage ./mxswitch {};
  m1ddc = pkgs.m1ddc.overrideAttrs (old: {
    # 1.2.0 uses address 0x50 for LG input switching but checksums with 0x51.
    # Backport https://github.com/waydabber/m1ddc/pull/52.
    patches =
      (old.patches or [])
      ++ [
        (pkgs.fetchurl {
          url = "https://github.com/waydabber/m1ddc/commit/5f15c8e4fa4d3c119aacd52a3fc9cec84b037fbe.patch";
          hash = "sha256-txL9yeYVuPWX2I1jKlio6r7Y7UTw/vIfYIUerlQkcSE=";
        })
      ];
  });
  selectHost = target:
    pkgs.writeShellScript "switch-to-${target}" ''
      ${lib.optionalString (target == "pc") ''
        ${pkgs.coreutils}/bin/timeout --kill-after=1s 8s \
          ${mxswitch}/bin/mxswitch ${toString hosts.pcChannel} || true
      ''}
      # The display is optional: keyboard/mouse switching also works undocked.
      if ! displays=$(${pkgs.coreutils}/bin/timeout --kill-after=1s 8s ${m1ddc}/bin/m1ddc display list detailed); then
        echo "Skipping LG input switch: no external display or detection failed" >&2
        exit 0
      fi
      # Match the LG by serial; display numbers and UUIDs can change between ports.
      display=$(${pkgs.gawk}/bin/awk -v serial=${lib.escapeShellArg sec.lgDisplay.serial} '
          /^\[/ { id = $NF; gsub(/[()]/, "", id) }
          $2 == "AN" && $3 == "Serial:" && $4 == serial { print id; exit }
        ' <<< "$displays")
      [[ -n "$display" ]] || exit 0
      # Run even if the mouse is unavailable, including when selecting this Mac.
      if ! ${pkgs.coreutils}/bin/timeout --kill-after=1s 8s \
        ${m1ddc}/bin/m1ddc display "$display" set input-alt ${toString sec.lgDisplay.inputs.${target}}; then
        echo "Skipping LG input switch: display disconnected or DDC command failed" >&2
      fi
    '';
  terminals = ["^org\\.alacritty$" "^io\\.alacritty$" "^com\\.apple\\.Terminal$"];
  browsers = ["^org\\.mozilla\\.firefox$" "^org\\.nixos\\.firefox$" "^com\\.apple\\.Safari$" "^com\\.google\\.Chrome$"];
  firefox = ["^org\\.mozilla\\.firefox$" "^org\\.nixos\\.firefox$"];

  inApp = ids: {
    type = "frontmost_application_if";
    bundle_identifiers = ids;
  };
  notInApp = ids: {
    type = "frontmost_application_unless";
    bundle_identifiers = ids;
  };
  onBuiltIn = {
    type = "device_if";
    identifiers = [{is_built_in_keyboard = true;}];
  };

  remap = {
    from,
    mandatory ? [],
    optional ? [],
    to ? from,
    mods ? [],
    when ? [],
  }: {
    type = "basic";
    from = {
      key_code = from;
      modifiers.mandatory = mandatory;
      modifiers.optional = optional;
    };
    to = [
      {
        key_code = to;
        modifiers = mods;
      }
    ];
    conditions = when;
  };

  # NB: Right (not left) Cmd for the split rule below that turns off left_command only
  ctrlToCmd = {
    k,
    shift ? null,
    exclude ? [],
  }:
    remap {
      from = k;
      mandatory = ["control"] ++ lib.optional (shift == true) "shift";
      optional = ["caps_lock"] ++ lib.optional (shift == null) "shift";
      mods = ["right_command"] ++ lib.optional (shift == true) "left_shift";
      when = [(notInApp (terminals ++ exclude))];
    };

  leftCmdToCmdAlt = k:
    remap {
      from = k;
      mandatory = ["left_command"];
      mods = ["left_command" "left_option"];
    };

  shiftSwap = from: to: [
    (remap {
      inherit from to;
      mandatory = ["left_shift"];
    })
    (remap {
      inherit from to;
      mods = ["left_shift"];
    })
  ];

  rule = description: manipulators: {inherit description manipulators;};

  config = {
    global = {
      check_for_updates_on_startup = false;
      show_in_menu_bar = false;
      show_profile_name_in_menu_bar = false;
    };
    profiles = [
      {
        name = "Default";
        selected = true;
        virtual_hid_keyboard.keyboard_type_v2 = "ansi";

        complex_modifications.rules = [
          (rule "ZMK: select PC or Mac for keyboard, mouse and LG display" [
            {
              type = "basic";
              from = {
                key_code = "f24";
                modifiers.optional = ["any"];
              };
              to = [
                {
                  shell_command = "${selectHost "pc"}";
                  repeat = false;
                }
              ];
            }
            {
              type = "basic";
              from = {
                key_code = "f23";
                modifiers.optional = ["any"];
              };
              to = [
                {
                  shell_command = "${selectHost "mac"}";
                  repeat = false;
                }
              ];
            }
          ])

          (rule "Built-in keyboard: F4 = screenshot selection (clipboard / +Ctrl = file)" [
            (remap {
              from = "f4";
              mandatory = ["control"];
              to = "f14";
              mods = ["left_shift"];
              when = [onBuiltIn];
            })
            (remap {
              from = "f4";
              to = "f13";
              mods = ["left_shift"];
              when = [onBuiltIn];
            })
          ])

          (rule "Built-in keyboard: F5 → F15 (mic mute, handled by AeroSpace)" [
            (remap {
              from = "f5";
              to = "f15";
              optional = ["any"];
              when = [onBuiltIn];
            })
          ])

          (rule "Built-in keyboard: Caps→Esc, Fn→Ctrl, ISO backtick fixes" [
            (remap {
              from = "caps_lock";
              to = "escape";
              optional = ["any"];
              when = [onBuiltIn];
            })
            (remap {
              from = "fn";
              to = "left_control";
              when = [onBuiltIn];
            })
            (remap {
              from = "non_us_backslash";
              to = "grave_accent_and_tilde";
              optional = ["any"];
              when = [onBuiltIn];
            })
            (remap {
              from = "grave_accent_and_tilde";
              to = "left_shift";
              optional = ["left_control"];
              when = [onBuiltIn];
            })
          ])

          (rule "Firefox: Cmd+Q close window instead of quitting" [
            (remap {
              from = "q";
              to = "w";
              mandatory = ["command"];
              optional = ["caps_lock"];
              mods = ["left_command" "left_shift"];
              when = [(inApp firefox)];
            })
          ])

          (rule "Linux muscle-memory: Ctrl+key → Cmd+key (non-terminal)"
            (map ctrlToCmd (
              map (k: {inherit k;}) ["c" "v" "x" "z" "a" "s" "f" "r" "n" "t" "w"]
              ++ [
                {
                  k = "l";
                  shift = false;
                  exclude = firefox;
                }
                {
                  k = "l";
                  shift = true;
                  exclude = browsers;
                }
              ]
            )))

          (rule "Terminal: Ctrl+Shift+C/V → Cmd+C/V (copy/paste)"
            (map (k:
              remap {
                from = k;
                mandatory = ["control" "shift"];
                mods = ["right_command"];
                when = [(inApp terminals)];
              }) ["c" "v"]))

          (rule "Cmd+C/V → Cmd+Alt+C/V (AeroSpace split-direction preselect)"
            (map leftCmdToCmdAlt ["c" "v"]))

          (rule "JIS japanese_kana → ':' plain / ';' shift"
            (shiftSwap "japanese_kana" "semicolon"))

          (rule "JIS international3 (Yen) → '?' plain / '/' shift"
            (shiftSwap "international3" "slash"))
        ];
      }
    ];
  };
in {
  home.packages = [mxswitch m1ddc];
  home.file.".config/karabiner/karabiner.json" = {
    force = true;
    text = builtins.toJSON config;
  };
}
