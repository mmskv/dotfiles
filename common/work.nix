{
  lib,
  sec,
  config,
  ...
}: let
  cfg = config.custom.work;
in {
  config = lib.mkIf cfg.enable {
    services.openvpn.servers = sec.wintermute.ovpn.servers;

    services.dnsmasq = {
      enable = true;

      settings = sec.work.dnsmasq.settings;
    };
  };
}
