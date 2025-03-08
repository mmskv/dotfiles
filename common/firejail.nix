{
  lib,
  pkgs,
  config,
  ...
}: let
  cfg = config.common.desktop.firejail;

  defaultConfig = ''
    # Allow screensharing under Wayland.
    dbus-user.talk org.freedesktop.portal.Desktop

    whitelist-ro ~/work
    whitelist-ro ~/shad
  '';
in {
  options.common.desktop.firejail.enable =
    lib.mkEnableOption "Firejail";

  config = lib.mkIf cfg.enable {
    programs.firejail = {
      enable = true;
      wrappedBinaries = {
        telegram-desktop = {
          executable = "${pkgs.telegram-desktop}/bin/telegram-desktop";
          profile = "${pkgs.firejail}/etc/firejail/telegram-desktop.profile";
        };

        google-chrome-stable = {
          executable = "${pkgs.google-chrome}/bin/google-chrome-stable";
          profile = "${pkgs.firejail}/etc/firejail/google-chrome.profile";
        };
      };
    };

    environment.etc = {
      "firejail/firejail.config".text = ''
        browser-allow-drm yes
      '';
      "firejail/telegram-desktop.local".text =
        defaultConfig
        + ''
          ignore nodbus
          dbus-user filter
          dbus-user.own org.mozilla.firefox.*

          noblacklist ''${HOME}/.mozilla
          whitelist ''${HOME}/.mozilla

          private-bin firefox
        '';
      "firejail/google-chrome.local".text = defaultConfig;
    };
  };
}
