{
  lib,
  sec,
  config,
  inputs,
  ...
}: {
  imports = [
    ./options.nix
    ./packages.nix
    ./hardening.nix

    ./desktop.nix
    ./hyprland.nix
  ];

  # agenix loads before impermanence
  age.identityPaths = ["/persist/etc/ssh/ssh_host_ed25519_key"];

  hardware.enableRedistributableFirmware = true;

  boot.zfs.forceImportRoot = false;
  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];

      connect-timeout = 5;
      stalled-download-timeout = 20;
    };

    # resolve nix-shell trough flake's nixpkgs instead of nix-channel
    registry.nixpkgs.flake = inputs.nixpkgs;
    nixPath = ["nixpkgs=flake:nixpkgs"];
  };

  time.timeZone = sec.timezone;

  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings.LC_TIME = "en_GB.UTF-8";
  };

  programs = {
    fish.enable = true;
    nix-index.enable = true;
    nix-index.enableFishIntegration = false;
    command-not-found.enable = false;
    neovim = {
      enable = true;
      defaultEditor = true;
    };
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
  };

  systemd.targets = {
    sleep.enable = false;
    suspend.enable = false;
    hibernate.enable = false;
    hybrid-sleep.enable = false;
  };

  services = {
    zfs.trim.enable = true;
    zfs.autoScrub.enable = true;
    ucodenix.enable = true;
    openssh = {
      allowSFTP = false;
      openFirewall = true;
      enable = true;
      settings = {
        AllowUsers = ["suck"] ++ lib.optionals (!config.custom.desktop.enable) ["root"];
        PasswordAuthentication = false;
      };
    };
  };

  documentation.dev.enable = true;
}
