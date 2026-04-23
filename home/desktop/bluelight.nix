{
  pkgs,
  pkgs-unstable,
  ...
}: let
  brightnessUpdateScript = pkgs.writeShellScriptBin "brightness-update" ''
    hour=$(date +%H)
    if [ "$hour" -ge 6 ] && [ "$hour" -lt 19 ]; then
      if ! ${pkgs.hyprland}/bin/hyprctl hyprsunset identity 2>/dev/null; then
        systemctl --user restart hyprsunset.service
        sleep 2
        ${pkgs.hyprland}/bin/hyprctl hyprsunset identity
      fi
    else
      if ! ${pkgs.hyprland}/bin/hyprctl hyprsunset temperature 3000 2>/dev/null; then
        systemctl --user restart hyprsunset.service
        sleep 2
        ${pkgs.hyprland}/bin/hyprctl hyprsunset temperature 3000
      fi
    fi
  '';
in {
  services.hyprsunset = {
    enable = true;
    package = pkgs-unstable.hyprsunset;
  };

  # Override the service to not auto-restart
  systemd.user.services.hyprsunset = {
    Service = {
      Restart = pkgs.lib.mkForce "no";
    };
  };

  systemd.user.services.brightness-update = {
    Unit = {
      Description = "Update monitor brightness based on time of day";
      Requires = ["hyprsunset.service"];
      ConditionEnvironment = ["WAYLAND_DISPLAY"];
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${brightnessUpdateScript}/bin/brightness-update";
    };
  };

  systemd.user.timers.brightness-update = {
    Unit = {
      Description = "Timer for brightness updates";
    };
    Timer = {
      OnCalendar = ["*-*-* 06:00:00" "*-*-* 19:00:00"];
      Persistent = true;
    };
    Install = {
      WantedBy = ["graphical-session.target"];
    };
  };
}
