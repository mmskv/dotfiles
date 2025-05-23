{
  lib,
  pkgs,
  sec,
  config,
  ...
}: let
  cfg = config.common.desktop;
in {
  options.common.desktop.enable =
    lib.mkEnableOption "System is a desktop";

  config = lib.mkIf cfg.enable {
    inherit (sec) networking;

    common.desktop = {
      hyprland.enable = true;
      firejail.enable = true;
    };

    services = {
      pipewire = {
        enable = true;
        pulse.enable = true;
      };

      blueman.enable = true;
      gvfs.enable = true;
      tumbler.enable = true;
    };

    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
    };

    virtualisation.podman = {
      enable = true;
      autoPrune.enable = true;
      dockerCompat = true;
    };
    systemd.services.podman.wantedBy = []; # disable start on boot

    programs.firefox.enable = true;

    users = {
      mutableUsers = false;

      users.suck = {
        isNormalUser = true;
        hashedPassword = sec.suck.passwd;

        home = "/home/suck";
        extraGroups = [
          "wheel"
          "podman"
        ];
        shell = pkgs.fish;
      };
    };

    security = {
      rtkit.enable = true;
      sudo.enable = false;
      doas = {
        enable = true;
        extraRules = [
          {
            users = ["suck"];
            keepEnv = true;
            noPass = true;
          }
        ];
      };
    };

    nixpkgs.config.allowUnfreePredicate = pkg:
      builtins.elem (lib.getName pkg) [
        "google-chrome"
        "obsidian"
        "anydesk"
        "corefonts"
        "gh-copilot"
      ];
  };
}
