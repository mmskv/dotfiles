{
  config,
  lib,
  pkgs,
  sec,
  ...
}: let
  # alacritty with custom bundle identifier for clipse floating rule
  clipseAlacrittyApp = pkgs.runCommandLocal "alacritty-clipse-bundle" {} ''
    src=${pkgs.alacritty}/Applications/Alacritty.app
    dst=$out/Applications/Alacritty-clipse.app
    mkdir -p "$(dirname "$dst")"
    cp -R "$src" "$dst"
    chmod -R u+w "$dst"
    sed -i \
      -e 's|<string>org\.alacritty</string>|<string>org.alacritty.clipse</string>|g' \
      -e 's|<string>io\.alacritty</string>|<string>org.alacritty.clipse</string>|g' \
      "$dst/Contents/Info.plist"
  '';
in {
  imports = [
    ../options.nix
    ../minimal

    ../desktop/firefox
    ../desktop/theme.nix
    ../desktop/alacritty.nix

    ./gpg.nix
    ./karabiner.nix
    ./open-in-vim.nix
  ];

  programs.home-manager.enable = true;

  home.file.".hushlogin".text = ""; # Suppress "Last login: ..." banner

  home = {
    username = sec.mac.user;
    homeDirectory = sec.mac.homeDir;

    sessionVariables = {
      NH_FLAKE = "${config.home.homeDirectory}/dotfiles";
      NH_BYPASS_ROOT_CHECK = "true";
      MOZ_ENABLE_WAYLAND = lib.mkForce "";
    };

    stateVersion = "24.11";
  };

  programs.alacritty.settings = {
    font.size = 14;
    selection.save_to_clipboard = true;
    mouse.bindings = [
      {
        mouse = "Middle";
        action = "PasteSelection";
      }
    ];
  };

  programs.fish.functions.xdragon = {
    description = "Copy a file to the clipboard as a file object";
    body = ''
      if test (count $argv) -ne 1
          echo "usage: xdragon <file>" >&2
          return 1
      end
      set -l path (realpath -- $argv[1])
      if not test -e $path
          echo "xdragon: $path does not exist" >&2
          return 1
      end
      osascript -l JavaScript -e 'function run(argv) {
        ObjC.import("AppKit");
        const url = $.NSURL.fileURLWithPath(argv[0]);
        const pb = $.NSPasteboard.generalPasteboard;
        pb.clearContents;
        pb.writeObjects($.NSArray.arrayWithObject(url));
      }' -- $path
    '';
  };

  home.packages = [pkgs.clipse clipseAlacrittyApp];
  launchd.agents.clipse = {
    enable = true;
    config = {
      ProgramArguments = ["${pkgs.clipse}/bin/clipse" "-listen-shell"];
      RunAtLoad = true;
      KeepAlive = true;
      StandardOutPath = "${config.home.homeDirectory}/Library/Logs/clipse.log";
      StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/clipse.log";
    };
  };
}
