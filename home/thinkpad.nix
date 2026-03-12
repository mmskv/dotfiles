{
  pkgs,
  pkgs-unstable,
  lib,
  config,
  sec,
  ...
}: let
  # Install a file to a root-owned path, only updating when content changes.
  # Optional postInstall runs after a successful install.
  installSystemFile = {
    dest,
    content,
    postInstall ? "",
  }:
    lib.hm.dag.entryAfter ["writeBoundary"] ''
      DEST="${dest}"
      TMP="$HOME/.cache/hm-install-$(echo "${dest}" | tr '/' '-').tmp"
      printf '%s' ${lib.escapeShellArg content} > "$TMP"

      if test ! -f "$DEST" || ! /usr/bin/sudo diff -q "$TMP" "$DEST" >/dev/null 2>&1; then
        echo "Installing $DEST..."
        run /usr/bin/sudo install -m 0644 "$TMP" "$DEST"
        ${postInstall}
      fi
      rm -f "$TMP"
    '';
in {
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
  programs.man.generateCaches = true;

  programs.matterhorn = {
    enable = true;
    extraConfig = sec.matterhornConfig;
  };

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

  home.activation.installHyprlockPam = installSystemFile {
    dest = "/etc/pam.d/hyprlock";
    content = ''
      #%PAM-1.0
      auth    include common-auth
      account include common-account
      password include common-password
      session include common-session
    '';
  };

  home.activation.installWifiResume = installSystemFile {
    dest = "/etc/systemd/system/wifi-resume.service";
    content = ''
      [Unit]
      Description=Restart WiFi after resume from suspend
      After=suspend.target

      [Service]
      Type=oneshot
      ExecStart=/usr/bin/nmcli radio wifi off
      ExecStartPost=/usr/bin/sleep 2
      ExecStartPost=/usr/bin/nmcli radio wifi on

      [Install]
      WantedBy=suspend.target
    '';
    postInstall = ''
      run /usr/bin/sudo systemctl daemon-reload
      run /usr/bin/sudo systemctl enable wifi-resume.service
    '';
  };

  home.activation.installVpnDispatcher = installSystemFile {
    dest = "/etc/NetworkManager/dispatcher.d/99-restart-wb-vpn";
    content = ''
      #!/bin/bash
      IFACE="$1"
      ACTION="$2"
      if [ "$ACTION" = "up" ] && nmcli -t -f TYPE connection show --active 2>/dev/null | grep -q wifi; then
        systemctl restart wb_vpn 2>/dev/null || true
      fi
    '';
    postInstall = ''
      run /usr/bin/sudo chmod 755 /etc/NetworkManager/dispatcher.d/99-restart-wb-vpn
    '';
  };

  home.activation.fixWbVpnService = lib.hm.dag.entryAfter ["writeBoundary"] ''
    if test -f /etc/systemd/system/wb_vpn.service; then
      if ! grep -q "network-online.target" /etc/systemd/system/wb_vpn.service; then
        echo "Updating wb_vpn.service to depend on network-online.target..."
        run /usr/bin/sudo ${pkgs.gnused}/bin/sed -i 's|After=network.target|After=network-online.target\nWants=network-online.target|' /etc/systemd/system/wb_vpn.service
        run /usr/bin/sudo systemctl daemon-reload
      fi
    fi
  '';

  xdg.configFile."pipewire/pipewire.conf.d/10-fix-sof-hda.conf".text = ''
    context.properties = {
      default.clock.rate = 48000
      default.clock.allowed-rates = [ 48000 ]
      default.clock.quantum = 1024
      default.clock.min-quantum = 1024
      default.clock.max-quantum = 2048
    }
  '';

  xdg.configFile."wireplumber/wireplumber.conf.d/51-alsa-headroom.conf".text = ''
    monitor.alsa.rules = [
      {
        matches = [
          { node.name = "~alsa_output.*" }
        ]
        actions = {
          update-props = {
            api.alsa.headroom = 1024
          }
        }
      }
    ]
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
