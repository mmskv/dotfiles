{...}: {
  environment.persistence."/persist" = {
    enable = true;
    hideMounts = true;
    directories = [
      "/var/log"
      "/var/lib/nixos"
      "/var/lib/systemd/coredump"
      "/var/cache/containers"
      "/var/lib/containers"
    ];
    files = [
      "/etc/zfs/zpool.cache"
      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_ed25519_key.pub"
      "/etc/ssh/ssh_host_rsa_key"
      "/etc/ssh/ssh_host_rsa_key.pub"
    ];
  };

  fileSystems."/persist" = {
    device = "wrpool/persist";
    fsType = "zfs";
    neededForBoot = true;
  };
}
