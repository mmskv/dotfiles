{
  lib,
  pkgs,
  sec,
  ...
}: {
  imports = [./hyprland.nix ./firejail.nix];

  inherit (sec) networking;

  systemd.targets = {
    sleep.enable = false;
    suspend.enable = false;
    hibernate.enable = false;
    hybrid-sleep.enable = false;
  };

  services = {
    pipewire = {
      enable = true;
      pulse.enable = true;
    };

    blueman.enable = true;
    gvfs.enable = true;
    tumbler.enable = true;
  };

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  virtualisation.podman = {
    enable = true;
    autoPrune.enable = true;
    dockerCompat = true;
  };
  systemd.services.podman.wantedBy = []; # disable start on boot

  programs = {
    fish.enable = true;
    firefox.enable = true;
    ssh.startAgent = true;
  };

  programs.bash.interactiveShellInit = ''
    if [[ $(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING} ]]
    then
       shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
       exec ${pkgs.fish}/bin/fish $LOGIN_OPTION
    fi
  '';

  users = {
    mutableUsers = false;

    users.suck = {
      isNormalUser = true;
      hashedPassword = sec.suck.passwd;

      home = "/home/suck";
      extraGroups = [
        "wheel"
        "podman"
      ];
      shell = pkgs.fish;
    };
  };

  security = {
    rtkit.enable = true;
    sudo.enable = false;
    doas = {
      enable = true;
      extraRules = [
        {
          users = ["suck"];
          keepEnv = true;
          noPass = true;
        }
      ];
    };
  };

  documentation.dev.enable = true;

  environment.systemPackages = with pkgs; [
    jq
    grc

    telegram-desktop
    google-chrome

    pkgs.man-pages
    pkgs.man-pages-posix

    (pkgs.writeShellScriptBin "vim" "exec nvim $@")
    (pkgs.writeShellScriptBin "sudo" "exec doas $@")
  ];

  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "google-chrome"
      "obsidian"
      "anydesk"
      "corefonts"
      "cursor"
    ];
}
