{pkgs, ...}: {
  environment.systemPackages = [pkgs.smartmontools];

  services.prometheus.exporters.smartctl = {
    enable = true;
    port = 9633;
    devices = ["/dev/sda" "/dev/sdb"];
  };

  networking.firewall.allowedTCPPorts = [9633];
}
