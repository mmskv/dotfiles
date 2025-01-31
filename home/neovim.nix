{pkgs, ...}: {
  home.packages = with pkgs; [
    typescript-language-server
    lua-language-server
    nixd
    gcc
    prettierd
    pyright
    clang-tools
    yamlfmt
    isort
    black
  ];

  programs.neovim.extraPackages = with pkgs; [gcc];
}
