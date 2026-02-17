{...}: {
  imports = [
    ./options.nix
    ./desktop
  ];

  programs.home-manager.enable = true;

  home = {
    username = "suck";
    homeDirectory = "/home/suck";
    stateVersion = "24.11";

    sessionVariables = {
      NH_FLAKE = "$HOME/dotfiles";
    };
  };
}
