{pkgs ? import <nixpkgs> {}}:
pkgs.mkShell {
  packages = [
    (builtins.getFlake "github:ryantm/agenix").packages.x86_64-linux.default
  ];
}
