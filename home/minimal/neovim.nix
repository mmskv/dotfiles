{
  pkgs,
  lib,
  ...
}: {
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    withRuby = false;
    withPython3 = false;
    withNodeJs = false;
  };

  # I have my own init.lua outside of nix
  xdg.configFile."nvim/init.lua".enable = lib.mkForce false;

  home.packages = with pkgs; [
    tree-sitter
    vtsls
    tailwindcss-language-server
    lua-language-server
    gopls
    nixd
    gcc
    go
    gotools
    prettierd
    basedpyright
    clang-tools
    yamlfmt
    isort
    black
    markdownlint-cli
    nodejs_24
    alejandra
  ];
}
