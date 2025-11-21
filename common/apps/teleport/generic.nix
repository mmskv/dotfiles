{
  lib,
  buildGoModule,
  fetchFromGitHub,
  makeWrapper,
  libfido2,
  openssl,
  pkg-config,
  stdenv,
  xdg-utils,
  version,
  hash,
  vendorHash,
  extPatches ? null,
}: let
  # This repo has a private submodule "e" which fetchgit cannot handle without failing.
  src = fetchFromGitHub {
    owner = "gravitational";
    repo = "teleport";
    rev = "v${version}";
    inherit hash;
  };
in
  buildGoModule rec {
    pname = "teleport-tsh";

    inherit src version;
    inherit vendorHash;
    proxyVendor = true;

    subPackages = ["tool/tsh"];
    tags = ["libfido2"];

    buildInputs = [openssl libfido2];
    nativeBuildInputs = [makeWrapper pkg-config];

    patches =
      lib.optionals (extPatches != null) extPatches
      ++ [
        ./0001-fix-add-nix-path-to-exec-env.patch
      ];

    # Multiple tests fail in the build sandbox
    # due to trying to spawn nixbld's shell (/noshell), etc.
    doCheck = false;

    postInstall = ''
      # make xdg-open overrideable at runtime
      wrapProgram $out/bin/tsh --suffix PATH : ${lib.makeBinPath [xdg-utils]}
    '';

    doInstallCheck = true;

    installCheckPhase = ''
      $out/bin/tsh version | grep ${version} > /dev/null
    '';

    meta = with lib; {
      description = "Teleport SSH client (tsh)";
      homepage = "https://goteleport.com/";
      license = licenses.asl20;
      maintainers = with maintainers; [arianvp justinas sigma tomberek freezeboy techknowlogick];
      platforms = platforms.unix;
      # go-libfido2 is broken on platforms with less than 64-bit because it defines an array
      # which occupies more than 31 bits of address space.
      broken = stdenv.hostPlatform.parsed.cpu.bits < 64;
    };
  }
