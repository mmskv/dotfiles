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

    # DDC support for hyprland
    boot.kernelModules = ["i2c-dev"];
    services.udev.extraRules = ''
      KERNEL=="i2c-[0-9]*", GROUP="wheel", MODE="0660"
    '';

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

    virtualisation.docker = {
      enable = true;
    };

    programs.firefox.enable = true;

    users = {
      mutableUsers = false;

      users.suck = {
        isNormalUser = true;
        hashedPassword = sec.suck.passwd;

        home = "/home/suck";
        extraGroups = [
          "wheel"
          "docker"
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

    nixpkgs.config.allowUnfree = true;
  };
}
