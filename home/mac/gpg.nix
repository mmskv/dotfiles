{
  pkgs,
  sec,
  ...
}: let
  pinentryShim = pkgs.writeShellScriptBin "pinentry-shim" ''
    printf 'OK Pleased to meet you\n'
    while IFS= read -r line; do
      case "''${line%% *}" in
        GETPIN) printf 'D %s\nOK\n' '${sec.mac.openpgpPin}' ;;
        BYE)    printf 'OK closing connection\n'; exit 0 ;;
        *)      printf 'OK\n' ;;
      esac
    done
  '';
in {
  programs.gpg = {
    enable = true;
    scdaemonSettings = {
      disable-ccid = true;
      pcsc-shared = true;
    };
  };

  services.gpg-agent = {
    enable = true;
    pinentry.package = pinentryShim;
  };
}
