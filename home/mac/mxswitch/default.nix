{lib, stdenv, fetchFromGitHub, darwin}:
stdenv.mkDerivation {
  pname = "mxswitch";
  version = "2026-09-07";
  src = fetchFromGitHub {
    owner = "marcocosta97";
    repo = "mxswitch";
    rev = "562847bb8335d557a0ea265e90a701519d70b479";
    hash = "sha256-qfyEKzZwT9B7VACoNttgyesMSfB2Caz3Mh3zSD+M5TM=";
  };
  nativeBuildInputs = [darwin.sigtool];
  buildPhase = ''
    runHook preBuild
    $CC -O2 -Wall -Wextra -o mxswitch macos/mxswitch.c \
      -framework IOKit -framework CoreFoundation -framework CoreGraphics
    runHook postBuild
  '';
  installPhase = ''
    runHook preInstall
    install -Dm755 mxswitch $out/bin/mxswitch
    install -Dm644 LICENSE $out/share/licenses/mxswitch/LICENSE
    runHook postInstall
  '';
  postFixup = ''
    codesign --force --sign - --identifier org.local.mxswitch $out/bin/mxswitch
  '';
  meta = {
    description = "Switch Logitech Easy-Switch devices between paired hosts";
    homepage = "https://github.com/marcocosta97/mxswitch";
    license = lib.licenses.mit;
    platforms = lib.platforms.darwin;
    mainProgram = "mxswitch";
  };
}
