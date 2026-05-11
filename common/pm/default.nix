{
  buildGoModule,
  makeWrapper,
  libnotify,
  terminal-notifier,
  stdenv,
  lib,
}:
buildGoModule {
  pname = "pm";
  version = "0.1.0";
  src = ./.;
  vendorHash = null;
  env.CGO_ENABLED = "0";
  nativeBuildInputs = [makeWrapper];
  postInstall =
    if stdenv.hostPlatform.isDarwin
    then ''
      wrapProgram $out/bin/pm --prefix PATH : ${lib.makeBinPath [terminal-notifier]}
    ''
    else ''
      wrapProgram $out/bin/pm --prefix PATH : ${lib.makeBinPath [libnotify]}
    '';
  meta.mainProgram = "pm";
}
