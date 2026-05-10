{pkgs, ...}: let
  execName = "NeovimAlacritty";
  execScript = pkgs.writeShellScript execName ''
    exec ${pkgs.alacritty}/bin/alacritty --command ${pkgs.neovim}/bin/nvim "$@"
  '';
  infoPlist = ''
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
        <key>CFBundleIdentifier</key>
        <string>org.nixos.neovim-alacritty</string>
        <key>CFBundleName</key>
        <string>Neovim (Alacritty)</string>
        <key>CFBundleExecutable</key>
        <string>${execName}</string>
        <key>CFBundlePackageType</key>
        <string>APPL</string>
        <key>CFBundleVersion</key>
        <string>1.0</string>
        <key>CFBundleShortVersionString</key>
        <string>1.0</string>
        <key>CFBundleDocumentTypes</key>
        <array>
            <dict>
                <key>CFBundleTypeRole</key>
                <string>Editor</string>
                <key>LSHandlerRank</key>
                <string>Alternate</string>
                <key>LSItemContentTypes</key>
                <array>
                    <string>public.text</string>
                    <string>public.source-code</string>
                    <string>public.plain-text</string>
                    <string>public.shell-script</string>
                    <string>public.python-script</string>
                    <string>public.data</string>
                </array>
            </dict>
        </array>
        <key>NSHighResolutionCapable</key>
        <true/>
    </dict>
    </plist>
  '';
in {
  home.file = {
    "Applications/Neovim (Alacritty).app/Contents/MacOS/${execName}".source = execScript;
    "Applications/Neovim (Alacritty).app/Contents/Info.plist".text = infoPlist;
  };
}
