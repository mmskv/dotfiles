{...}: {
  services.chrony.extraConfig = ''
    allow 192.168.77.0/24
  '';

  networking.firewall.allowedUDPPorts = [123];
}
