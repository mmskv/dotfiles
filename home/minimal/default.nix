{lib, ...}: {
  imports = [
    ./shell.nix
    ./git.nix
    ./neovim.nix
  ];

  options.common.desktop.enable =
    lib.mkEnableOption "is desktop";
}
