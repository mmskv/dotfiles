{pkgs, ...}: let
  brightnessDayScript = pkgs.writeShellScriptBin "brightness-day" ''
    #${pkgs.ddcutil}/bin/ddcutil -d 1 setvcp 10 100 && \
    #${pkgs.ddcutil}/bin/ddcutil -d 2 setvcp 10 80 && \
    if ! ${pkgs.hyprland}/bin/hyprctl hyprsunset identity 2>/dev/null; then
      systemctl --user restart hyprsunset.service
      sleep 2
      ${pkgs.hyprland}/bin/hyprctl hyprsunset identity
    fi
  '';

  brightnessNightScript = pkgs.writeShellScriptBin "brightness-night" ''
    #${pkgs.ddcutil}/bin/ddcutil -d 1 setvcp 10 100 && \
    #${pkgs.ddcutil}/bin/ddcutil -d 2 setvcp 10 80 && \
    if ! ${pkgs.hyprland}/bin/hyprctl hyprsunset temperature 3000 2>/dev/null; then
      systemctl --user restart hyprsunset.service
      sleep 2
      ${pkgs.hyprland}/bin/hyprctl hyprsunset temperature 3000
    fi
  '';
in {
  services.hyprsunset.enable = true;

  # Override the service to not auto-restart
  systemd.user.services.hyprsunset = {
    Service = {
      Restart = pkgs.lib.mkForce "no";
    };
  };

  systemd.user.services = {
    brightness-day = {
      Unit = {
        Description = "Set monitor brightness for daytime";
        Requires = ["hyprsunset.service"];
        ConditionEnvironment = ["WAYLAND_DISPLAY"];
        ConditionTime = "06:00..19:00";
      };
      Service = {
        Type = "oneshot";
        ExecStart = "${brightnessDayScript}/bin/brightness-day";
      };
    };

    brightness-night = {
      Unit = {
        Description = "Set monitor brightness for nighttime";
        Requires = ["hyprsunset.service"];
        ConditionEnvironment = ["WAYLAND_DISPLAY"];
        ConditionTime = "19:00..06:00";
      };
      Service = {
        Type = "oneshot";
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
        OnCalendar = "*-*-* 19:00:00";
        Persistent = true;
      };
      Install = {
        WantedBy = ["graphical-session.target"];
      };
    };
  };
}
