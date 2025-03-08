{
  sec,
  pkgs,
  ...
}: {
  imports = [
    # ./zrepl.nix
    ./impermanence.nix
  ];

  users = {
    mutableUsers = false;

    users.root = {
      hashedPassword = sec.root.passwd;

      shell = pkgs.fish;
    };
  };

  hardware.cpu.intel.updateMicrocode = true;

  networking = {
    hostName = "Hosaka";
    hostId = sec.net.Hosaka.hostId;
    useDHCP = false;
    networkmanager.enable = false;

    interfaces.eno1.ipv4.addresses = [
      {
        address = sec.net.Hosaka.ip;
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
        device = "wrpool/nix";
        fsType = "zfs";
      };

      "/root" = {
        device = "wrpool/home/root";
        fsType = "zfs";
      };

      "/boot" = {
        device = "/dev/disk/by-id/${sec.disks.hosaka.main}-part1";
        fsType = "vfat";
        options = ["umask=0077"];
      };
    }
    // sec.hosaka.extraMounts;

  swapDevices = [{device = "/dev/disk/by-id/${sec.disks.hosaka.main}-part3";}];

  system.stateVersion = "24.11";
}
