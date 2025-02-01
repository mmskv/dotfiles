{
  pkgs,
  sec,
  ...
}: {
  imports = [./desktop.nix ./hardening.nix];

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

  services.ucodenix.enable = true;

  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

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
  ];
}
