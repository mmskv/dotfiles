{...}: {
  imports = [
    ./minimal
  ];

  programs.home-manager.enable = true;

  home = {
    username = "root";
    homeDirectory = "/root";

    sessionVariables = {
      FLAKE = "/root/dotfiles";
      NH_BYPASS_ROOT_CHECK = "true";
    };
  };

  home.stateVersion = "24.11";
}
