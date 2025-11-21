{pkgs, ...}: let
  brightnessDayScript = pkgs.writeShellScriptBin "brightness-day" ''
    ${pkgs.ddcutil}/bin/ddcutil -d 1 setvcp 10 100 && \
    ${pkgs.ddcutil}/bin/ddcutil -d 2 setvcp 10 80 && \
    ${pkgs.hyprland}/bin/hyprctl hyprsunset identity
  '';

  brightnessNightScript = pkgs.writeShellScriptBin "brightness-night" ''
    ${pkgs.ddcutil}/bin/ddcutil -d 1 setvcp 10 100 && \
    ${pkgs.ddcutil}/bin/ddcutil -d 2 setvcp 10 80 && \
    ${pkgs.hyprland}/bin/hyprctl hyprsunset temperature 3000
  '';
in {
  services.hyprsunset = {
    enable = true;
  };

  systemd.user.services = {
    brightness-day = {
      Unit = {
        Description = "Set monitor brightness for daytime";
        Requires = ["hyprsunset.service"];
        ConditionEnvironment = ["WAYLAND_DISPLAY"];
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
        Description = "Timer to set daytime monitor brightness every 15 minutes";
      };
      Timer = {
        # Run every 15 minutes from 06:00 through 18:59
        OnCalendar = "*-*-* 06..18:0/15:00";
        Persistent = true;
      };
      Install = {
        WantedBy = ["graphical-session.target"];
      };
    };

    brightness-night = {
      Unit = {
        Description = "Timer to set nighttime monitor brightness every 15 minutes";
      };
      Timer = {
        # Run every 15 minutes from 19:00-23:59 and 00:00-05:59
        OnCalendar = [
          "*-*-* 19..23:0/15:00"
          "*-*-* 00..05:0/15:00"
        ];
        Persistent = true;
      };
      Install = {
        WantedBy = ["graphical-session.target"];
      };
    };
  };
}
