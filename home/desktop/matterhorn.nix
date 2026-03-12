{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.programs.matterhorn;

  matterhorn = pkgs.stdenv.mkDerivation rec {
    pname = "matterhorn";
    version = "90000.1.1";

    src = pkgs.fetchurl {
      url = "https://github.com/matterhorn-chat/matterhorn/releases/download/${version}/matterhorn-${version}-ubuntu-22.04-jammy-x86_64.tar.bz2";
      hash = "sha256-NKkaPyqwRxMCSD5ghDzSDYGMD4CgZ9M90xtOv4atvX0=";
    };

    sourceRoot = "matterhorn-${version}-ubuntu-22.04-jammy-x86_64";

    nativeBuildInputs = [pkgs.autoPatchelfHook];
    buildInputs = [
      pkgs.zlib
      pkgs.ncurses
      pkgs.gmp
      pkgs.stdenv.cc.cc.lib
    ];

    installPhase = ''
      runHook preInstall

      mkdir -p $out/share/matterhorn $out/bin
      cp -r . $out/share/matterhorn/
      chmod +x $out/share/matterhorn/matterhorn
      ln -s $out/share/matterhorn/matterhorn $out/bin/matterhorn

      runHook postInstall
    '';
  };

  notifyScript = pkgs.writeShellScript "matterhorn-notify" ''
    export PATH="${lib.makeBinPath [pkgs.jq pkgs.libnotify]}:$PATH"
    exec ${matterhorn}/share/matterhorn/notification-scripts/notifyV2 "$@"
  '';

  formatValue = v:
    if builtins.isBool v
    then
      (
        if v
        then "True"
        else "False"
      )
    else toString v;

  configFile = pkgs.writeText "matterhorn-config.ini" ''
    [mattermost]
    ${lib.concatStringsSep "\n" (lib.mapAttrsToList (k: v: "${k}: ${formatValue v}") cfg.settings)}
    ${cfg.extraConfig}
  '';
in {
  options.programs.matterhorn = {
    enable = lib.mkEnableOption "matterhorn, a terminal Mattermost client";

    settings = lib.mkOption {
      type = with lib.types; attrsOf (oneOf [str int bool]);
      default = {};
      description = "Settings for the [mattermost] section in config.ini.";
      example = lib.literalExpression ''
        {
          host = "mattermost.example.com";
          user = "myuser";
          port = 443;
          theme = "builtin:dark";
          showTypingIndicator = true;
        }
      '';
    };

    extraConfig = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = "Extra lines to append to config.ini.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [matterhorn];

    programs.matterhorn.settings = {
      activityNotifyCommand = toString notifyScript;
      activityNotifyVersion = 2;
    };

    xdg.configFile."matterhorn/config.ini".source = configFile;
  };
}
