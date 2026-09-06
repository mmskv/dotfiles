{pkgs, ...}: let
  # Display 1 = LG UltraGear (DP-2), Display 2 = Xiaomi Mi Monitor (DP-3).
  ddcutil = "${pkgs.ddcutil}/bin/ddcutil";
  hyprctl = "${pkgs.hyprland}/bin/hyprctl";

  # ddcutil drives the monitor over I2C and needs no Wayland session, so it
  # always runs; only the hyprsunset call is gated on the session being up.
  # (Gating the whole unit on ConditionEnvironment=WAYLAND_DISPLAY made the
  # persistent catch-up run get skipped at login, leaving last night's values.)
  sunset = arg: ''
    if [ -n "''${WAYLAND_DISPLAY:-}" ]; then
      if ! ${hyprctl} hyprsunset ${arg} 2>/dev/null; then
        systemctl --user restart hyprsunset.service
        sleep 2
        ${hyprctl} hyprsunset ${arg}
      fi
    fi
  '';

  brightnessDayScript = pkgs.writeShellScriptBin "brightness-day" ''
    ${ddcutil} -d 1 setvcp 10 80
    ${ddcutil} -d 2 setvcp 10 80
    ${sunset "identity"}
  '';

  brightnessNightScript = pkgs.writeShellScriptBin "brightness-night" ''
    ${ddcutil} -d 1 setvcp 10 80
    ${ddcutil} -d 2 setvcp 10 70
    ${sunset "temperature 3000"}
  '';

  # systemd has no ConditionTime (it was silently ignored), and Persistent=true
  # means a missed run fires at session start whatever the hour — so gate on the
  # wall clock ourselves. ExecCondition exiting non-zero skips the unit cleanly.
  timeWindow = start: end:
    pkgs.writeShellScript "brightness-window-${toString start}-${toString end}" ''
      h=$(${pkgs.coreutils}/bin/date +%-H)
      ${
        if start < end
        then ''[ "$h" -ge ${toString start} ] && [ "$h" -lt ${toString end} ]''
        else ''[ "$h" -ge ${toString start} ] || [ "$h" -lt ${toString end} ]''
      }
    '';
in {
  services.hyprsunset.enable = true;

  # Auto-restart on crash (it SIGABRTs when Hyprland recreates the wl_output on
  # DPMS wake — see the NVIDIA udev-change churn), and silence default-trace spam.
  # RestartSec=10 (from the hyprsunset module) keeps this from tight-looping.
  systemd.user.services.hyprsunset = {
    Service = {
      Restart = pkgs.lib.mkForce "on-failure";
      LogLevelMax = "warning";
    };
  };

  systemd.user.services = {
    brightness-day = {
      Unit = {
        Description = "Set monitor brightness for daytime";
        Requires = ["hyprsunset.service"];
      };
      Service = {
        Type = "oneshot";
        ExecCondition = "${timeWindow 6 19}";
        ExecStart = "${brightnessDayScript}/bin/brightness-day";
      };
    };

    brightness-night = {
      Unit = {
        Description = "Set monitor brightness for nighttime";
        Requires = ["hyprsunset.service"];
      };
      Service = {
        Type = "oneshot";
        ExecCondition = "${timeWindow 19 6}";
        ExecStart = "${brightnessNightScript}/bin/brightness-night";
      };
    };
  };

  systemd.user.timers = {
    brightness-day = {
      Unit = {
        Description = "Timer to set daytime monitor brightness";
      };
      Timer = {
        OnCalendar = "*-*-* 06:00:00";
        Persistent = true;
      };
      Install = {
        WantedBy = ["graphical-session.target"];
      };
    };

    brightness-night = {
      Unit = {
        Description = "Timer to set nighttime monitor brightness";
      };
      Timer = {
        OnCalendar = "*-*-* 21:00:00";
        Persistent = true;
      };
      Install = {
        WantedBy = ["graphical-session.target"];
      };
    };
  };
}
