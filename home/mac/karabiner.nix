{lib, pkgs, sec, ...}: let
  hosts = sec.mouse;
  mxswitch = pkgs.callPackage ./mxswitch {};
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
          (rule "ZMK: select PC or Mac for both keyboard and mouse" [
            {
              type = "basic";
              from = {
                key_code = "f24";
                modifiers.optional = ["any"];
              };
              to = [{
                shell_command = "${pkgs.coreutils}/bin/timeout --kill-after=1s 8s ${mxswitch}/bin/mxswitch ${toString hosts.pcChannel}";
                repeat = false;
              }];
            }
            {
              type = "basic";
              from = {
                key_code = "f23";
                modifiers.optional = ["any"];
              };
              to = [{key_code = "vk_none";}];
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
  home.packages = [mxswitch];
  home.file.".config/karabiner/karabiner.json" = {
    force = true;
    text = builtins.toJSON config;
  };
}
