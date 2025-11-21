{
  lib,
  pkgs,
  sec,
  config,
  ...
}: let
  cfg = config.common.teleport;

  teleportPkgs = pkgs.callPackage ./apps/teleport {};
in {
  options.common.teleport.enable =
    lib.mkEnableOption "Hyprland";

  config = lib.mkIf cfg.enable {
    services.dnsmasq = {
      enable = true;

      settings = sec.work.dnsmasq.settings;
    };

    environment.systemPackages = [
      teleportPkgs.teleport
    ];
  };
}
