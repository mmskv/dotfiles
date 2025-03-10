{sec, ...}: {
  services.nfs = {
    server = {
      enable = true;
      exports = sec.hosaka.nfs.exports;
    };

    # reduce attack surface
    settings = {
      nfsd.udp = false;
      nfsd.vers3 = false;
      nfsd.vers4 = true;
      nfsd."vers4.0" = false;
      nfsd."vers4.1" = false;
      nfsd."vers4.2" = true;
    };
  };

  networking.firewall.allowedTCPPorts = [2049];
}
