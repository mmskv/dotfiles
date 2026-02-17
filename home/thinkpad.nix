{
  pkgs,
  pkgs-unstable,
  lib,
  config,
  ...
}: {
  imports = [
    ./options.nix
    ./desktop
  ];

  custom.workLaptop.enable = true;

  home = {
    username = "suck";
    homeDirectory = "/home/suck";
    stateVersion = "24.11";

    sessionVariables = {
      NH_FLAKE = "$HOME/dotfiles";
    };
  };

  programs.home-manager.enable = true;
  #programs.man.generateCaches = false;

  xdg.configFile."apparmor/nix-store-profile".text = ''
    abi <abi/4.0>,
    include <tunables/global>

    profile nix-firefox ${pkgs.firefox}/**/* flags=(default_allow) {
      userns,
    }

    profile nix-chrome ${pkgs.google-chrome}/**/* flags=(default_allow) {
      userns,
    }

    profile nix-code ${pkgs-unstable.vscode}/**/* flags=(default_allow) {
      userns,
    }
  '';

  home.activation.installAppArmor = lib.hm.dag.entryAfter ["writeBoundary"] ''
    SOURCE="${config.home.homeDirectory}/.config/apparmor/nix-store-profile"
    DEST="/etc/apparmor.d/nix-store-profiles"

    if ! diff -q "$SOURCE" "$DEST" &>/dev/null; then
      echo "AppArmor profile changed. Installing to /etc/apparmor.d/..."
      run /usr/bin/sudo cp "$SOURCE" "$DEST"
      run /usr/bin/sudo apparmor_parser -r "$DEST"
      echo "AppArmor profiles reloaded."
    fi
  '';

  home.activation.installHyprlockPam = lib.hm.dag.entryAfter ["writeBoundary"] ''
    DEST="/etc/pam.d/hyprlock"
    CONTENT="#%PAM-1.0
    auth    include common-auth
    account include common-account
    password include common-password
    session include common-session
    "

    TMP="$HOME/.cache/hyprlock-pam.tmp"
    printf '%s' "$CONTENT" > "$TMP"

    if test ! -f "$DEST" || ! /usr/bin/sudo diff -q "$TMP" "$DEST" >/dev/null 2>&1; then
      echo "Installing $DEST for hyprlock..."
      run /usr/bin/sudo install -m 0644 "$TMP" "$DEST"
    fi
    rm -f "$TMP"
  '';

  home.packages = with pkgs; [
    networkmanagerapplet
    blueman
    brightnessctl
    power-profiles-daemon
    google-chrome
    grim
    slurp
    alejandra
    teleport_17
    uwsm

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
    exiftool
    fd
    dogdns
    nh
    btop
    bpftrace
    parallel
    python3
    rustc
    cargo
    man-pages
    man-pages-posix
  ];
}
