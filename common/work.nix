{
  config,
  lib,
  sec,
  ...
}: let
  cfg = config.custom.work;
  vpn = sec.work.vpn;
  updateSystemdResolved = "${config.services.openvpn.package}/libexec/update-systemd-resolved";
in {
  config = lib.mkIf cfg.enable {
    services.resolved = {
      enable = true;
      settings.Resolve = {
        LLMNR = false;
        MulticastDNS = false;
      };
    };

    services.openvpn.servers =
      sec.wintermute.ovpn.servers
      // {
        work = {
          autoStart = false;
          config = ''
            ${vpn.profile}
            down-pre

            # Keep normal traffic and DNS outside the employer-controlled tunnel.
            pull-filter ignore "redirect-gateway"
            pull-filter ignore "dhcp-option DOMAIN"
            ${lib.concatMapStringsSep "\n" (domain: "dhcp-option DOMAIN-ROUTE ${domain}") vpn.dnsDomains}
          '';
          up = ''
            ${updateSystemdResolved}
            resolvectl default-route "$dev" no
          '';
          down = updateSystemdResolved;
          authUserPass = {
            inherit (vpn) username password;
          };
        };
      };

    # Authentication failures exit cleanly; never retry a bad password
    # indefinitely and risk locking the corporate account.
    systemd.services.openvpn-work.serviceConfig.Restart = lib.mkForce "on-failure";
  };
}
