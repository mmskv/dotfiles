{pkgs, ...}: {
  home.packages = with pkgs; [
    tree-sitter
    vtsls
    tailwindcss-language-server
    lua-language-server
    nixd
    gcc
    prettierd
    pyright
    clang-tools
    yamlfmt
    isort
    black
    markdownlint-cli
    nodejs_24
  ];
}
