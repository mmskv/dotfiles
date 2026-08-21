{
  lib,
  pkgs,
  pkgs-unstable,
  config,
  ...
}: let
  cfg = config.custom.desktop;
in {
  config = lib.mkIf cfg.enable {
    programs = {
      hyprland = {
        enable = true;

        package = pkgs.hyprland;
        portalPackage = pkgs.xdg-desktop-portal-hyprland;

        withUWSM = true;
      };
    };

    # don't restart wayland on nix configuration switch
    systemd.user.units =
      lib.genAttrs [
        "wayland-session-bindpid@.service"
        "wayland-wm@.service"
        "wayland-wm-env@.service"
        "wayland-session-waitenv.service"
        "wayland-wm-app-daemon.service"
      ] (_: {
        overrideStrategy = "asDropin";
        text = ''
          [Service]
          X-RestartIfChanged=false
        '';
      });

    services.xserver = {
      enable = true;
      displayManager.lightdm.enable = false;

      xkb.layout = "uscustom,rucustom";
      xkb.extraLayouts.rucustom = {
        description = "Russian layout with binds for my zmk config";
        languages = ["rus"];
        symbolsFile = pkgs.writeText "rucustom" ''
          default partial alphanumeric_keys
          xkb_symbols "rucustom" {
              include "ru(common)"

              name[Group1] = "Russian";

              key <AB10> {[ period, comma ]};
              key <AE13> {
                  type = "TWO_LEVEL",
                  symbols[Group1] = [ question ]
              };
              key <HKTG> {
                  type = "TWO_LEVEL",
                  symbols[Group1] = [ colon, semicolon ]
              };
          };
        '';
      };

      xkb.extraLayouts.uscustom = {
        description = "English (US) layout with binds for my zmk config";
        languages = ["eng"];
        symbolsFile = pkgs.writeText "uscustom" ''
          default partial alphanumeric_keys
          xkb_symbols "uscustom" {
              include "us(basic)"

              name[Group1] = "English (US)";

              key <AE13> {
                  type = "TWO_LEVEL",
                  symbols[Group1]= [ question ]
              };
              key <HKTG> {
                  type = "TWO_LEVEL",
                  symbols[Group1] = [ colon, semicolon ]
              };
          };
        '';
      };
    };
  };
}
