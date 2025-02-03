{sec, ...}: {
  imports = [
    ./amdgpu.nix
    ./zrepl.nix
    ./impermanence.nix
    ../../system
  ];

  networking = {
    hostName = "Wintermute";
    hostId = sec.net.hostId;
    useDHCP = false;
    networkmanager.enable = false;

    interfaces.eno1.ipv4.addresses = [
      {
        address = sec.net.Wintermute;
        prefixLength = 24;
      }
    ];

    defaultGateway = {
      address = sec.net.gw;
      interface = "eno1";
    };

    nameservers = [sec.net.ns];
    firewall.enable = true;
  };

  boot = {
    zfs.devNodes = "/dev/disk/by-id";
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    initrd.availableKernelModules = ["nvme"];
    tmp.useTmpfs = true;
  };

  fileSystems =
    {
      "/" = {
        device = "none";
        fsType = "tmpfs";
        options = ["defaults" "size=25%" "mode=755"];
      };

      "/nix" = {
        device = "rpool/nix";
        fsType = "zfs";
      };

      "/home" = {
        device = "rpool/home";
        fsType = "zfs";
      };

      "/boot" = {
        device = "/dev/disk/by-id/${sec.disks.wintermute.main}-part1";
        fsType = "vfat";
        options = ["umask=0077"];
      };

      "/var/lib/containers/storage" = {
        device = "rpool/containers";
        fsType = "zfs";
      };
    }
    // sec.wintermute.extraMounts;

  swapDevices = [
    {
      device = "/dev/disk/by-id/${sec.disks.wintermute.main}-part3";
    }
  ];

  system.stateVersion = "24.11";
}
