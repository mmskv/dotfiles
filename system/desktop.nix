{
  lib,
  pkgs,
  sec,
  ...
}:
{
  imports = [ ./hyprland.nix ];

  inherit (sec) networking;

  virtualisation.docker = {
    enable = true;
    enableOnBoot = false;
    storageDriver = "zfs";
    autoPrune.enable = true;
  };

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

  programs = {
    fish.enable = true;
    firefox.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
  };

  programs.bash.interactiveShellInit = ''
    if [[ $(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING} ]]
    then
      shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
      exec ${pkgs.fish}/bin/fish $LOGIN_OPTION
    fi
  '';

  users.users.suck = {
    isNormalUser = true;
    home = "/home/suck";
    extraGroups = [
      "wheel"
      "docker"
    ];
    shell = pkgs.fish;
  };

  security = {
    sudo.enable = false;
    doas = {
      enable = true;
      extraRules = [
        {
          users = [ "suck" ];
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

    pkgs.man-pages
    pkgs.man-pages-posix

    (pkgs.writeShellScriptBin "vim" "exec nvim $@")
    (pkgs.writeShellScriptBin "sudo" "exec doas $@")
  ];

  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "google-chrome"
      "obsidian"
      "corefonts"
      "cursor"
    ];
}
