{
  pkgs,
  lib,
  ...
}: let
  aerospace-swipe = pkgs.stdenv.mkDerivation {
    pname = "aerospace-swipe";
    version = "unstable-2025-11-17";

    src = pkgs.fetchFromGitHub {
      owner = "acsandmann";
      repo = "aerospace-swipe";
      rev = "976c3107f6ed9859149bdc130e3f8928f2ab6852";
      hash = "sha256-ARJfYiWXBCvXA5JlFl/s4VIQ9xuqBoU3gPfC8B2mkWI=";
    };

    nativeBuildInputs = [pkgs.darwin.sigtool];

    dontConfigure = true;

    buildPhase = ''
      runHook preBuild
      make all
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      install -Dm755 swipe $out/bin/aerospace-swipe
      runHook postInstall
    '';

    postFixup = ''
      codesign --entitlements accessibility.entitlements --force --sign - $out/bin/aerospace-swipe
    '';

    meta = {
      description = "Three-finger trackpad swipe to switch AeroSpace workspaces";
      homepage = "https://github.com/acsandmann/aerospace-swipe";
      license = lib.licenses.mit;
      platforms = lib.platforms.darwin;
      mainProgram = "aerospace-swipe";
    };
  };

  configDir = pkgs.writeTextDir "config.json" (builtins.toJSON {
    natural_swipe = true;
  });
in {
  environment.systemPackages = [aerospace-swipe];

  launchd.user.agents.aerospace-swipe = {
    serviceConfig = {
      Label = "com.acsandmann.swipe";
      ProgramArguments = ["${aerospace-swipe}/bin/aerospace-swipe"];
      WorkingDirectory = "${configDir}";
      EnvironmentVariables.PATH = lib.makeBinPath [pkgs.aerospace];
      RunAtLoad = true;
      KeepAlive = true;
      ProcessType = "Interactive";
      StandardOutPath = "/tmp/aerospace-swipe.out";
      StandardErrorPath = "/tmp/aerospace-swipe.err";
    };
  };
}
