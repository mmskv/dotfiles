{
  sec,
  lib,
  ...
}: {
  services.syncthing = {
    enable = true;
    guiAddress = "127.0.0.1:8384";

    settings = {
      devices = sec.syncthing.devices;

      folders = {
        "obsidian-vault" = {
          path = "~/self/brain";
          id = "obsidian-vault";
          label = "Obsidian Vault";
          devices = ["phone"];
          type = "sendreceive";
        };
      };

      options = {
        localAnnounceEnabled = true;
        localAnnouncePort = 21027;
        relaysEnabled = false;
        limitBandwidthInLan = false;
        urAccepted = -1;
      };
    };

    overrideDevices = false;
    overrideFolders = false;
  };

  # no autostart
  systemd.user.services.syncthing.Install.WantedBy = lib.mkForce [];
  systemd.user.services.syncthing-init.Install.WantedBy = lib.mkForce [];
}
