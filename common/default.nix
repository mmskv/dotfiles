{
  lib,
  pkgs,
  sec,
  config,
  ...
}: {
  imports = [
    ./desktop.nix
    ./firejail.nix
    ./hyprland.nix

    ./hardening.nix
  ];

  hardware.enableRedistributableFirmware = true;
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

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
        AllowUsers = ["suck"] ++ lib.optionals (!config.common.desktop.enable) ["root"];
        PasswordAuthentication = false;
      };
    };
  };

  documentation.dev.enable = true;

  environment.systemPackages = with pkgs; [
    openssh
    ripgrep
    wget
    git
    fzf
    file
    tcpdump
    bind
    git-crypt
    zoxide
    jq
    grc
    kubectl
    alejandra
    exiftool
    file
    fd
    dogdns
    nh

    # lang
    python3
    rustc
    rustup

    pkgs.man-pages
    pkgs.man-pages-posix

    (pkgs.writeShellScriptBin "vim" "exec nvim $@")
    (pkgs.writeShellScriptBin "sudo" "exec doas $@")
  ];
}
