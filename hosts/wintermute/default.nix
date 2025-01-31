{sec, ...}: {
  imports = [
    ./amdgpu.nix
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
        device = "rpool/ROOT/nixos";
        fsType = "zfs";
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
    }
    // sec.wintermute.extraMounts;

  swapDevices = [
    {
      device = "/dev/disk/by-id/${sec.disks.wintermute.main}-part3";
    }
  ];

  system.stateVersion = "24.11";
}
