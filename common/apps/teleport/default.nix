{
  callPackages,
  lib,
  ...
} @ args: let
  f = args: rec {
    teleport_13 = import ./13 args;
    teleport = teleport_13;
  };
  # Ensure the following callPackages invocation includes everything 'generic' needs.
  f' = lib.setFunctionArgs f (builtins.functionArgs (import ./generic.nix));
in
  callPackages f' (builtins.removeAttrs args ["callPackages"])
