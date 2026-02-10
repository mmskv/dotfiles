{
  lib,
  pkgs,
  sec,
  config,
  ...
}: let
  cfg = config.custom.desktop;
in {
  config = lib.mkIf cfg.enable {
    inherit (sec) networking;

    nixpkgs.config.allowUnfree = true;

    # DDC support for hyprland
    boot.kernelModules = ["i2c-dev"];
    services.udev.extraRules = ''
      KERNEL=="i2c-[0-9]*", GROUP="wheel", MODE="0660"
    '';

    services = {
      pipewire = {
        enable = true;
        pulse.enable = true;
        jack.enable = true;
        extraConfig.pipewire."99-adjust-sample-rate" = {
          "context.properties" = {
            "default.clock.rate" = 48000;
            "default.clock.allowed-rates" = [96000 48000 44100];
          };
        };

        wireplumber.extraConfig."51-rename-devices" = {
          "monitor.alsa.rules" = [
            {
              matches = [
                {"node.name" = "alsa_output.pci-0000_0b_00.6.pro-output-0";}
              ];
              actions = {
                update-props = {
                  "node.description" = "Headphones";
                };
              };
            }
            {
              matches = [
                {"node.name" = "alsa_output.pci-0000_0b_00.6.pro-output-1";}
              ];
              actions = {
                update-props = {
                  "node.description" = "Pioneer";
                };
              };
            }
          ];
        };
      };

      blueman.enable = true;
      gvfs.enable = true;
      tumbler.enable = true;
    };

    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
    };

    virtualisation.docker.enable = true;

    users = {
      mutableUsers = false;

      users.suck = {
        isNormalUser = true;
        hashedPassword = sec.suck.passwd;

        home = "/home/suck";
        extraGroups = [
          "wheel"
          "docker"
          "systemd-journal"
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
  };
}
