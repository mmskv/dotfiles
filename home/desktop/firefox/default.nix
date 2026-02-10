{
  lib,
  pkgs,
  sec,
  ...
}: let
  extraConfig =
    builtins.readFile "${pkgs.arkenfox-userjs}/user.js"
    + "\n"
    +
    #js
    ''
      user_pref('security.OCSP.require', false);
      user_pref('browser.sessionstore.resume_from_crash', false);
      user_pref('ui.systemUsesDarkTheme', 1);
      user_pref('network.trr.uri', ${sec.net.doh});
      user_pref('network.trr.custom_uri', ${sec.net.doh});

      user_pref('browser.translations.automaticallyPopup', false);
      user_pref('identity.fxaccounts.enabled', false);
      user_pref('signon.showAutoCompleteFooter', false);
      user_pref('browser.urlbar.maxHistoricalSearchSuggestions', 0);
    '';
in {
  imports = [
    ./tridactyl.nix
  ];

  home.sessionVariables.MOZ_ENABLE_WAYLAND = "1";

  programs.firefox = {
    enable = true;

    nativeMessagingHosts = [pkgs.tridactyl-native];

    policies = {
      DisplayBookmarksToolbar = "never";
      DefaultDownloadDirectory = "\${home}/Downloads";
      Cookies.Allow = sec.allowCookies;

      ExtensionSettings = {
        "*" = {
          installation_mode = "blocked";
        };

        "{17c7f098-dbb8-4f15-ad39-8b578da80f7e}" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/behave/latest.xpi";
          installation_mode = "force_installed";
        };

        "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/bitwarden-password-manager/latest.xpi";
          default_area = "navbar";
          installation_mode = "force_installed";
        };

        "uBlock0@raymondhill.net" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
          installation_mode = "force_installed";
        };

        "addon@darkreader.org" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/darkreader/latest.xpi";
          installation_mode = "force_installed";
        };

        "firefox-compact-dark@mozilla.org" = {
          installation_mode = "force_installed";
        };

        "tridactyl.vim.betas@cmcaine.co.uk" = {
          install_url = "https://tridactyl.cmcaine.co.uk/betas/tridactyl-latest.xpi";
          installation_mode = "force_installed";
        };
      };
    };

    profiles.default = {
      id = 0;
      name = "default";
      path = "hm.default";
      isDefault = true;

      inherit extraConfig;
    };

    profiles.proxied = {
      id = 1;
      name = "proxied";
      path = "hm.proxied";

      inherit extraConfig;

      settings.network.proxy = {
        type = lib.mkForce 1;
        socks = lib.mkForce "127.0.0.1";
        socks_port = lib.mkForce 1080;
        socks_version = lib.mkForce 5;
        socks_remote_dns = lib.mkForce true;
      };
    };
  };
}
