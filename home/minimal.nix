{...}: {
  imports = [
    ./options.nix
    ./minimal
  ];

  programs.home-manager.enable = true;

  home = {
    username = "root";
    homeDirectory = "/root";

    sessionVariables = {
      NH_FLAKE = "$HOME/dotfiles";
      NH_BYPASS_ROOT_CHECK = "true";
    };
  };

  home.stateVersion = "24.11";
}
