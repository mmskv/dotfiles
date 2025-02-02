{
  pkgs,
  config,
  ...
}: {
  # https://github.com/Kicksecure/security-misc
  # https://github.com/cynicsketch/nix-mineral

  services.chrony = {
    enable = true;
    enableNTS = true;
    servers = ["time.cloudflare.com"];
    extraConfig = ''
      authselectmode require
      cmdport 0
    '';
    extraFlags = ["-F 1"];
  };

  services.openssh.settings.PermitRootLogin = "no";

  systemd.tmpfiles.settings = {
    "restricthome"."/home/*".Z.mode = "~0700";
    "restrictetcnixos"."/etc/nixos/*".Z = {
      mode = "0000";
      user = "root";
      group = "root";
    };
  };

  nix.settings.allowed-users = ["@wheel"];

  programs.git = {
    enable = true;
    config = {
      core.symlinks = false;
      transfer.fsckobjects = true;
      fetch.fsckobjects = true;
      receive.fsckobjects = true;
    };
  };

  hardware.bluetooth.settings = {
    Policy.Privacy = "network/on";
  };

  environment.etc.machine-id.text = "b08dfa6083e7567a1921a715000001fb";

  boot.specialFileSystems = {
    "/dev/shm" = {options = ["noexec"];};
    "/run" = {options = ["noexec"];};
    "/dev" = {options = ["noexec"];};

    # Hide processes from other users except root, may cause breakage.
    # See overrides, in desktop section.
    "/proc" = {
      device = "proc";
      options = [
        "hidepid=2"
        "gid=${toString config.users.groups.proc.gid}"
      ];
    };
  };

  users.groups.proc.gid = config.ids.gids.proc;
  systemd.services.systemd-logind.serviceConfig.SupplementaryGroups = ["proc"];
  systemd.services."user@".serviceConfig.SupplementaryGroups = ["proc"];

  boot.loader.systemd-boot.editor = false;

  boot.kernel.sysctl = {
    "dev.tty.ldisc_autoload" = 0;
    "fs.protected_fifos" = 2;
    "fs.protected_hardlinks" = 1;
    "fs.protected_regular" = 2;
    "fs.protected_symlinks" = 1;
    "kernel.dmesg_restrict" = 1;
    "kernel.ftrace_enabled" = false;
    "kernel.kptr_restrict" = 1;
    "kernel.perf_event_paranoid" = 3;
    "kernel.printk" = "4 4 3 4";
    "kernel.randomize_va_space" = 2;
    "kernel.sysrq" = 0;
    "kernel.unprivileged_bpf_disabled" = 1;
    "kernel.yama.ptrace_scope" = 2;
    "module.sig_enforce" = 1;
    "net.core.bpf_jit_enable" = false;
    "net.ipv4.tcp_timestamps" = 1;
  };

  boot.kernelParams = [
    "page_poison=1"
    "page_alloc.shuffle=1"
  ];

  boot.extraModprobeConfig =
    # bash
    ''
      ## https://github.com/Kicksecure/security-misc/blob/master/etc/modprobe.d/30_security-misc_disable.conf
      ## FireWire (IEEE 1394):
      ## Disable IEEE 1394 (FireWire/i.LINK/Lynx) modules to prevent some DMA attacks.
      ##
      ## https://en.wikipedia.org/wiki/IEEE_1394#Security_issues
      ##
      install dv1394 ${pkgs.coreutils}/bin/true
      install firewire-core ${pkgs.coreutils}/bin/true
      install firewire-ohci ${pkgs.coreutils}/bin/true
      install firewire-net ${pkgs.coreutils}/bin/true
      install firewire-sbp2 ${pkgs.coreutils}/bin/true
      install ohci1394 ${pkgs.coreutils}/bin/true
      install raw1394 ${pkgs.coreutils}/bin/true
      install sbp2 ${pkgs.coreutils}/bin/true
      install video1394 ${pkgs.coreutils}/bin/true

      ## Global Positioning Systems (GPS):
      ## Disable GPS-related modules like GNSS (Global Navigation Satellite System).
      ##
      install garmin_gps ${pkgs.coreutils}/bin/true
      install gnss ${pkgs.coreutils}/bin/true
      install gnss-mtk ${pkgs.coreutils}/bin/true
      install gnss-serial ${pkgs.coreutils}/bin/true
      install gnss-sirf ${pkgs.coreutils}/bin/true
      install gnss-ubx ${pkgs.coreutils}/bin/true
      install gnss-usb ${pkgs.coreutils}/bin/true

      ## Intel Platform Monitoring Technology (PMT) Telemetry:
      ## Disable some functionality of the Intel PMT components.
      ##
      ## https://github.com/intel/Intel-PMT
      ##
      install pmt_class ${pkgs.coreutils}/bin/true
      install pmt_crashlog ${pkgs.coreutils}/bin/true
      install pmt_telemetry ${pkgs.coreutils}/bin/true

      ## Thunderbolt:
      ## Disables Thunderbolt modules to prevent some DMA attacks.
      ##
      ## https://en.wikipedia.org/wiki/Thunderbolt_(interface)#Security_vulnerabilities
      ##
      install intel-wmi-thunderbolt ${pkgs.coreutils}/bin/true
      install thunderbolt ${pkgs.coreutils}/bin/true
      install thunderbolt_net ${pkgs.coreutils}/bin/true

      ## 2. File Systems:

      ## File Systems:
      ## Disable uncommon file systems to reduce attack surface.
      ## HFS/HFS+ are legacy Apple file systems that may be required depending on the EFI partition format.
      ##
      install cramfs ${pkgs.coreutils}/bin/true
      install freevxfs ${pkgs.coreutils}/bin/true
      install hfs ${pkgs.coreutils}/bin/true
      install hfsplus ${pkgs.coreutils}/bin/true
      install jffs2 ${pkgs.coreutils}/bin/true
      install jfs ${pkgs.coreutils}/bin/true
      install reiserfs ${pkgs.coreutils}/bin/true
      install udf ${pkgs.coreutils}/bin/true

      ## Network File Systems:
      ## Disable uncommon network file systems to reduce attack surface.
      ##
      install gfs2 ${pkgs.coreutils}/bin/true
      install ksmbd ${pkgs.coreutils}/bin/true
      ##
      ## Common Internet File System (CIFS):
      ##
      install cifs ${pkgs.coreutils}/bin/true
      install cifs_arc4 ${pkgs.coreutils}/bin/true
      install cifs_md4 ${pkgs.coreutils}/bin/true
      ##
      ## Network File System (NFS):
      ##
      install nfs_acl ${pkgs.coreutils}/bin/true
      install nfs_layout_nfsv41_files ${pkgs.coreutils}/bin/true
      install nfs_layout_flexfiles ${pkgs.coreutils}/bin/true
      install nfsd ${pkgs.coreutils}/bin/true
      install nfsv2 ${pkgs.coreutils}/bin/true
      install nfsv3 ${pkgs.coreutils}/bin/true

      ## 2. Networking:

      ## Network Protocols:
      ## Disables rare and unneeded network protocols that are a common source of unknown vulnerabilities.
      ## Previously had blacklisted eepro100 and eth1394.
      ##
      ## https://tails.boum.org/blueprint/blacklist_modules/
      ## https://fedoraproject.org/wiki/Security_Features_Matrix#Blacklist_Rare_Protocols
      ## https://git.launchpad.net/ubuntu/+source/kmod/tree/debian/modprobe.d/blacklist-rare-network.conf?h=ubuntu/disco
      ## https://github.com/Kicksecure/security-misc/pull/234#issuecomment-2230732015
      ##
      install af_802154 ${pkgs.coreutils}/bin/true
      install appletalk ${pkgs.coreutils}/bin/true
      install ax25 ${pkgs.coreutils}/bin/true
      install brcm80211 ${pkgs.coreutils}/bin/true
      install decnet ${pkgs.coreutils}/bin/true
      install dccp ${pkgs.coreutils}/bin/true
      install econet ${pkgs.coreutils}/bin/true
      install eepro100 ${pkgs.coreutils}/bin/true
      install eth1394 ${pkgs.coreutils}/bin/true
      install ipx ${pkgs.coreutils}/bin/true
      install n-hdlc ${pkgs.coreutils}/bin/true
      install netrom ${pkgs.coreutils}/bin/true
      install p8022 ${pkgs.coreutils}/bin/true
      install p8023 ${pkgs.coreutils}/bin/true
      install psnap ${pkgs.coreutils}/bin/true
      install rose ${pkgs.coreutils}/bin/true
      install x25 ${pkgs.coreutils}/bin/true
      ##
      ## Asynchronous Transfer Mode (ATM):
      ##
      install atm ${pkgs.coreutils}/bin/true
      install ueagle-atm ${pkgs.coreutils}/bin/true
      install usbatm ${pkgs.coreutils}/bin/true
      install xusbatm ${pkgs.coreutils}/bin/true
      ##
      ## Controller Area Network (CAN) Protocol:
      ##
      install c_can ${pkgs.coreutils}/bin/true
      install c_can_pci ${pkgs.coreutils}/bin/true
      install c_can_platform ${pkgs.coreutils}/bin/true
      install can ${pkgs.coreutils}/bin/true
      install can-bcm ${pkgs.coreutils}/bin/true
      install can-dev ${pkgs.coreutils}/bin/true
      install can-gw ${pkgs.coreutils}/bin/true
      install can-isotp ${pkgs.coreutils}/bin/true
      install can-raw ${pkgs.coreutils}/bin/true
      install can-j1939 ${pkgs.coreutils}/bin/true
      install can327 ${pkgs.coreutils}/bin/true
      install ifi_canfd ${pkgs.coreutils}/bin/true
      install janz-ican3 ${pkgs.coreutils}/bin/true
      install m_can ${pkgs.coreutils}/bin/true
      install m_can_pci ${pkgs.coreutils}/bin/true
      install m_can_platform ${pkgs.coreutils}/bin/true
      install phy-can-transceiver ${pkgs.coreutils}/bin/true
      install slcan ${pkgs.coreutils}/bin/true
      install ucan ${pkgs.coreutils}/bin/true
      install vxcan ${pkgs.coreutils}/bin/true
      install vcan ${pkgs.coreutils}/bin/true
      ##
      ## Transparent Inter Process Communication (TIPC):
      ##
      install tipc ${pkgs.coreutils}/bin/true
      install tipc_diag ${pkgs.coreutils}/bin/true
      ##
      ## Reliable Datagram Sockets (RDS):
      ##
      install rds ${pkgs.coreutils}/bin/true
      install rds_rdma ${pkgs.coreutils}/bin/true
      install rds_tcp ${pkgs.coreutils}/bin/true
      ##
      ## Stream Control Transmission Protocol (SCTP):
      ##
      install sctp ${pkgs.coreutils}/bin/true
      install sctp_diag ${pkgs.coreutils}/bin/true

      ## 4. Miscellaneous:

      ## Amateur Radios:
      ##
      install hamradio ${pkgs.coreutils}/bin/true

      ## CPU Model-Specific Registers (MSRs):
      ## Disable CPU MSRs as they can be abused to write to arbitrary memory.
      ##
      ## https://security.stackexchange.com/questions/119712/methods-root-can-use-to-elevate-itself-to-kernel-mode
      ## https://github.com/Kicksecure/security-misc/issues/215
      ##
      install msr ${pkgs.coreutils}/bin/true

      ## Floppy Disks:
      ##
      install floppy ${pkgs.coreutils}/bin/true

      ## Framebuffer (fbdev):
      ## Video drivers are known to be buggy, cause kernel panics, and are generally only used by legacy devices.
      ## These were all previously blacklisted.
      ##
      ## https://docs.kernel.org/fb/index.html
      ## https://en.wikipedia.org/wiki/Linux_framebuffer
      ## https://git.launchpad.net/ubuntu/+source/kmod/tree/debian/modprobe.d/blacklist-framebuffer.conf?h=ubuntu/disco
      ##
      install aty128fb ${pkgs.coreutils}/bin/true
      install atyfb ${pkgs.coreutils}/bin/true
      install cirrusfb ${pkgs.coreutils}/bin/true
      install cyber2000fb ${pkgs.coreutils}/bin/true
      install cyblafb ${pkgs.coreutils}/bin/true
      install gx1fb ${pkgs.coreutils}/bin/true
      install hgafb ${pkgs.coreutils}/bin/true
      install i810fb ${pkgs.coreutils}/bin/true
      install intelfb ${pkgs.coreutils}/bin/true
      install kyrofb ${pkgs.coreutils}/bin/true
      install lxfb ${pkgs.coreutils}/bin/true
      install matroxfb_base ${pkgs.coreutils}/bin/true
      install neofb ${pkgs.coreutils}/bin/true
      install nvidiafb ${pkgs.coreutils}/bin/true
      install pm2fb ${pkgs.coreutils}/bin/true
      install radeonfb ${pkgs.coreutils}/bin/true
      install rivafb ${pkgs.coreutils}/bin/true
      install s1d13xxxfb ${pkgs.coreutils}/bin/true
      install savagefb ${pkgs.coreutils}/bin/true
      install sisfb ${pkgs.coreutils}/bin/true
      install sstfb ${pkgs.coreutils}/bin/true
      install tdfxfb ${pkgs.coreutils}/bin/true
      install tridentfb ${pkgs.coreutils}/bin/true
      install vesafb ${pkgs.coreutils}/bin/true
      install vfb ${pkgs.coreutils}/bin/true
      install viafb ${pkgs.coreutils}/bin/true
      install vt8623fb ${pkgs.coreutils}/bin/true
      install udlfb ${pkgs.coreutils}/bin/true

      ## Replaced Modules:
      ## These legacy drivers have all been entirely replaced and superseded by newer drivers.
      ## These were all previously blacklisted.
      ##
      ## https://git.launchpad.net/ubuntu/+source/kmod/tree/debian/modprobe.d/blacklist.conf?h=ubuntu/disco
      ##
      install asus_acpi ${pkgs.coreutils}/bin/true
      install bcm43xx ${pkgs.coreutils}/bin/true
      install de4x5 ${pkgs.coreutils}/bin/true
      install prism54 ${pkgs.coreutils}/bin/true

      ## Vivid:
      ## Disables the vivid kernel module since it has been the cause of multiple vulnerabilities.
      ##
      ## https://forums.whonix.org/t/kernel-recompilation-for-better-hardening/7598/233
      ## https://www.openwall.com/lists/oss-security/2019/11/02/1
      ## https://github.com/a13xp0p0v/kconfig-hardened-check/commit/981bd163fa19fccbc5ce5d4182e639d67e484475
      ##
      install vivid ${pkgs.coreutils}/bin/true

      ## Additional modprobe configuration for uncovered modules
      ##
      install adfs ${pkgs.coreutils}/bin/true
      install affs ${pkgs.coreutils}/bin/true
      install befs ${pkgs.coreutils}/bin/true
      install bfs ${pkgs.coreutils}/bin/true
      install efs ${pkgs.coreutils}/bin/true
      install erofs ${pkgs.coreutils}/bin/true
      install exofs ${pkgs.coreutils}/bin/true
      install f2fs ${pkgs.coreutils}/bin/true
      install hpfs ${pkgs.coreutils}/bin/true
      install nilfs2 ${pkgs.coreutils}/bin/true
      install omfs ${pkgs.coreutils}/bin/true
      install squashfs ${pkgs.coreutils}/bin/true
      install memstick ${pkgs.coreutils}/bin/true
      install nfc ${pkgs.coreutils}/bin/true
      install soundwire-bus ${pkgs.coreutils}/bin/true
      install minix ${pkgs.coreutils}/bin/true
      install qnx4 ${pkgs.coreutils}/bin/true
      install qnx6 ${pkgs.coreutils}/bin/true
      install sysv ${pkgs.coreutils}/bin/true
    '';
}
