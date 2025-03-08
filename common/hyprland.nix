{
  lib,
  pkgs,
  config,
  ...
}: let
  cfg = config.common.desktop.hyprland;
in {
  options.common.desktop.hyprland.enable =
    lib.mkEnableOption "Hyprland";

  config = lib.mkIf cfg.enable {
    programs = {
      uwsm = {
        enable = true;
        waylandCompositors = {
          hyprland = {
            prettyName = "Hyprland";
            binPath = "/run/current-system/sw/bin/Hyprland";
          };
        };
      };

      hyprland = {
        enable = true;
        withUWSM = true;
      };
    };

    services.xserver = {
      enable = true;
      displayManager.lightdm.enable = false;

      xkb.layout = "uscustom,rucustom";
      xkb.extraLayouts.rucustom = {
        description = "Russian layout with some binds for my zmk config";
        languages = ["rus"];
        symbolsFile = pkgs.writeText "rucustom" ''
          default partial alphanumeric_keys
          xkb_symbols "rucustom" {
              include "ru(common)"

              name[Group1]= "Russian";

              key <AB10>	{[     period,       comma  ]};
              key <AE13> {
                  type= "TWO_LEVEL",
                  symbols[Group1]= [ question ]
              };
              key <HKTG> {
                  type= "TWO_LEVEL",
                  symbols[Group1]= [ colon, semicolon ]
              };
          };
        '';
      };

      xkb.extraLayouts.uscustom = {
        description = "English (US) layout with some binds for my zmk config";
        languages = ["eng"];
        symbolsFile = pkgs.writeText "uscustom" ''
          default partial alphanumeric_keys
          xkb_symbols "uscustom" {
              include "us(basic)"

              name[Group1]= "English (US)";

              key <AE13> {
                  type= "TWO_LEVEL",
                  symbols[Group1]= [ question ]
              };
              key <HKTG> {
                  type= "TWO_LEVEL",
                  symbols[Group1]= [ colon, semicolon ]
              };
          };
        '';
      };
    };
  };
}
