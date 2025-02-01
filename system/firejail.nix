{pkgs, ...}: let
  default = ''
    # Allow screensharing under Wayland.
    dbus-user.talk org.freedesktop.portal.Desktop

    whitelist-ro ~/work
  '';
in {
  programs.firejail = {
    enable = true;
    wrappedBinaries = {
      telegram-desktop = {
        executable = "${pkgs.telegram-desktop}/bin/telegram-desktop";
        profile = "${pkgs.firejail}/etc/firejail/telegram-desktop.profile";
      };

      firefox = {
        executable = "${pkgs.firefox}/bin/firefox";
        profile = "${pkgs.firejail}/etc/firejail/firefox.profile";
      };

      google-chrome-stable = {
        executable = "${pkgs.google-chrome}/bin/google-chrome-stable";
        profile = "${pkgs.firejail}/etc/firejail/google-chrome.profile";
      };
    };
  };

  environment.etc = {
    "firejail/telegram-desktop.local".text = default;
    "firejail/firefox.local".text = default;
    "firejail/google-chrome.local".text = default;
  };
}
