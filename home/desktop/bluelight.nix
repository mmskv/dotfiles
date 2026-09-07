{
  config,
  lib,
  pkgs,
  ...
}: let
  schedule = {
    day = "06:00";
    night = "21:00";
  };
  nightTemperature = 3000;
  dayProfile = {identity = true;};
  nightProfile = {temperature = nightTemperature;};
  forcedProfile = name: profile:
    pkgs.writeText "hyprsunset-${name}.conf" (lib.hm.generators.toHyprconf {
      attrs.profile = [({time = "00:00";} // profile)];
    });
  policy = pkgs.writeText "display-mode.json" (builtins.toJSON {
    inherit schedule nightTemperature;
    profiles = {
      auto = config.xdg.configFile."hypr/hyprsunset.conf".source;
      day = forcedProfile "day" dayProfile;
      night = forcedProfile "night" nightProfile;
    };
    commands = {
      hyprctl = "${pkgs.hyprland}/bin/hyprctl";
      hyprsunset = lib.getExe config.services.hyprsunset.package;
      ddcutil = "${pkgs.ddcutil}/bin/ddcutil";
      systemctl = "${pkgs.systemd}/bin/systemctl";
    };
    monitors = [
      {
        name = "LG UltraGear";
        mfg = "GSM";
        model = "LG ULTRAGEAR+";
        serial = "511NTYTGR482";
        day = 80;
        night = 80;
      }
      {
        name = "Xiaomi Mi Monitor";
        mfg = "XMI";
        model = "Mi Monitor";
        serial = "";
        day = 80;
        night = 70;
      }
    ];
  });
  worker = "${pkgs.python3}/bin/python3 ${./display-mode.py} --config ${policy}";
in {
  services.hyprsunset = {
    enable = true;
    # 0.3.3 fails to consume --config's argument, then rejects the filename.
    package = pkgs.hyprsunset.overrideAttrs (old: {
      postPatch =
        (old.postPatch or "")
        + ''
          substituteInPlace src/main.cpp \
            --replace-fail 'configPath = argv[i + 1];' 'configPath = argv[++i];'
        '';
    });
    settings.profile = [
      ({time = schedule.day;} // dayProfile)
      ({time = schedule.night;} // nightProfile)
    ];
  };

  # A forced mode uses a single native profile, so clock transitions cannot
  # undo it. Every daemon start reads the persisted mode before connecting.
  systemd.user.services.hyprsunset.Service.ExecStart =
    lib.mkForce "${worker} run-hyprsunset";

  # Start display-mode@day, @night or @auto. No RemainAfterExit: starting the
  # same instance again must reapply it. The selected mode persists on disk.
  systemd.user.services."display-mode@" = {
    Unit = {
      Description = "Select display mode: %i";
      PartOf = ["graphical-session.target"];
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${worker} select-mode %i";
      TimeoutStartSec = 90;
    };
  };

  # Hardware brightness has its own lifecycle and never starts/restarts the
  # color daemon. Each run recomputes the target from the current time/mode.
  systemd.user.services.display-brightness = {
    Unit = {
      Description = "Apply the current display brightness profile";
      After = ["graphical-session.target"];
      PartOf = ["graphical-session.target"];
      ConditionEnvironment = "HYPRLAND_INSTANCE_SIGNATURE";
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${worker} apply-brightness";
      TimeoutStartSec = 45;
    };
    Install.WantedBy = ["graphical-session.target"];
  };

  # Cheap IPC checks detect wake/hotplug and retry unavailable DDC displays.
  # Successful unchanged displays are only verified over I2C once a minute.
  systemd.user.timers.display-brightness = {
    Unit.PartOf = ["graphical-session.target"];
    Timer = {
      OnActiveSec = "1s";
      OnUnitInactiveSec = "5s";
      AccuracySec = "1s";
    };
    Install.WantedBy = ["graphical-session.target"];
  };

  systemd.user.services.display-refresh = {
    Unit = {
      Description = "Recheck display brightness after wake";
      PartOf = ["graphical-session.target"];
      ConditionEnvironment = "HYPRLAND_INSTANCE_SIGNATURE";
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${worker} refresh";
      TimeoutStartSec = 45;
    };
  };

  services.hypridle.settings.general.after_sleep_cmd = "${pkgs.systemd}/bin/systemctl --user --no-block start display-refresh.service";
}
