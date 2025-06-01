{...}: {
  imports = [
    ./desktop
  ];

  programs.home-manager.enable = true;
  common.desktop.enable = true;

  home = {
    username = "suck";
    homeDirectory = "/home/suck";
  };

  home.stateVersion = "24.11";
}
