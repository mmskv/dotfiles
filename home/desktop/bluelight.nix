{pkgs, ...}: let
  brightnessDayScript = pkgs.writeShellScriptBin "brightness-day" ''
    ${pkgs.ddcutil}/bin/ddcutil -d 1 setvcp 10 80 && \
    ${pkgs.ddcutil}/bin/ddcutil -d 2 setvcp 10 80
  '';

  brightnessNightScript = pkgs.writeShellScriptBin "brightness-night" ''
    ${pkgs.ddcutil}/bin/ddcutil -d 1 setvcp 10 40 && \
    ${pkgs.ddcutil}/bin/ddcutil -d 2 setvcp 10 40
  '';
in {
  services.hyprsunset = {
    enable = true;

    transitions = {
      day = {
        calendar = "*-*-* 06:00:00";
        requests = [
          ["temperature" "6500"]
        ];
      };
      night = {
        calendar = "*-*-* 19:00:00";
        requests = [
          ["temperature" "3000"]
        ];
      };
    };
  };

  systemd.user.services = {
    brightness-day = {
      Unit = {
        Description = "Set monitor brightness for daytime";
      };
      Service = {
        Type = "oneshot";
        ExecStart = "${brightnessDayScript}/bin/brightness-day";
      };
    };

    brightness-night = {
      Unit = {
        Description = "Set monitor brightness for nighttime";
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
        WantedBy = ["timers.target"];
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
        WantedBy = ["timers.target"];
      };
    };
  };
}
