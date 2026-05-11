{
  pkgs,
  sec,
  ...
}: {
  imports = [
    ../options.nix
    ./aerospace.nix
    ./aerospace-swipe.nix
    ./sketchybar.nix
    ./vpn.nix
  ];

  nixpkgs.hostPlatform = "aarch64-darwin";
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    ripgrep
    neovim
    wget
    git
    fzf
    file
    git-crypt
    zoxide
    jq
    grc
    kubectl
    exiftool
    fd
    btop
    parallel
    bind
    dogdns
    nh
    python3
    rustc
    cargo
    rust-analyzer
    glab
    (openvpn.override {pkcs11Support = true;})
    yubikey-manager
    yubico-piv-tool
    opensc
    gnupg
    terraform
    terragrunt
    openssh
    wireguard-tools

    (writeShellScriptBin "vim" "exec nvim $@")
  ];

  environment.etc."libykcs11.dylib".source = "${pkgs.yubico-piv-tool}/lib/libykcs11.dylib";
  environment.etc."opensc-pkcs11.so".source = "${pkgs.opensc}/lib/opensc-pkcs11.so";

  environment.variables = {
    LANG = "en_US.UTF-8";
    LC_TIME = "en_GB.UTF-8";
    LC_MEASUREMENT = "en_GB.UTF-8";
  };

  programs = {
    fish.enable = true;
    nix-index.enable = true;
  };

  system.defaults = {
    dock.autohide = true;
    dock.autohide-delay = 1000.0;
    dock.autohide-time-modifier = 0.0;
    dock.show-recents = false;
    dock.static-only = true;

    finder.AppleShowAllExtensions = true;
    finder.FXPreferredViewStyle = "clmv";
    screencapture.location = "~/Downloads/screenshots";
    screensaver.askForPasswordDelay = 10;

    CustomSystemPreferences = {
      "/Library/Preferences/com.apple.security.smartcard" = {
        DisabledTokens = ["com.apple.CryptoTokenKit.pivtoken"];
      };
    };

    CustomUserPreferences = {
      NSGlobalDomain = {
        "com.apple.mouse.linear" = true;
        "com.apple.sound.beep.volume" = 0.0;
        "com.apple.sound.uiaudio.enabled" = 0;
        "AppleLanguages" = ["en-US"];
        "AppleLocale" = "en_GB";
        "AppleMeasurementUnits" = "Centimeters";
        "AppleMetricUnits" = 1;
        "AppleTemperatureUnit" = "Celsius";
        "InitialKeyRepeat" = 25;
        "KeyRepeat" = 2.35;
      };
      "com.caldis.Mos" = {
        smooth = true;
        reverse = true;
        reverseMouse = true;
        reverseTrackpad = false;
      };
    };
  };

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
  };

  time.timeZone = sec.timezone;

  power.sleep.display = 10;

  # Stop media keys (play/pause/next/prev) from launching Music.app
  launchd.user.agents.disable-rcd = {
    serviceConfig = {
      Label = "org.local.disable-rcd";
      ProgramArguments = [
        "/bin/sh"
        "-c"
        ''
          uid=$(id -u)
          /bin/launchctl disable "user/$uid/com.apple.rcd" || true
          /bin/launchctl bootout  "gui/$uid/com.apple.rcd"  || true
        ''
      ];
      RunAtLoad = true;
      KeepAlive = false;
    };
  };

  nix.enable = true;
}
