args:
import ../generic.nix (args
  // {
    version = "13.4.14";
    hash = "sha256-g11D5lekI3pUpKf5CLUuNjejs0gN/bEemHkCj3akha0=";
    vendorHash = "sha256-kiDhlR/P81u/yNq72JuskES/UzMrTFzJT0H3xldGk8I=";
    extPatches = [
      # https://github.com/NixOS/nixpkgs/issues/120738
      ../tsh.patch
    ];
  })
