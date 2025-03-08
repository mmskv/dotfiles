{...}: {
  imports = [
    ./minimal
  ];

  programs.home-manager.enable = true;

  home = {
    username = "root";
    homeDirectory = "/root";
  };

  home.stateVersion = "24.11";
}
