{
  desktopTheme,
  pkgs,
  ...
}: let
  inherit (desktopTheme) colors fonts metrics;
  rgba = color: alpha: "${color}${alpha}";
in {
  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        fields = "exec,filename,name,generic";
        terminal = "''${pkgs.alacritty}/bin/alacritty";
        font = "${fonts.ui}:size=${toString metrics.launcher.fontSize}";
        anchor = "top";
        icons-enabled = "no";
        lines = 1;
        hide-before-typing = "yes";
        horizontal-pad = metrics.launcher.horizontalPadding;
        vertical-pad = metrics.launcher.verticalPadding;
        launch-prefix = "uwsm app -- ";
      };

      colors = {
        background = rgba colors.background "AA";
        text = rgba colors.foreground "FF";
        selection-text = rgba colors.foreground "FF";
        selection-match = rgba colors.white "FF";
        border = rgba colors.accentMuted "FF";
        selection = rgba colors.black "00";
        prompt = rgba colors.prompt "FF";
        input = rgba colors.prompt "FF";
      };

      border = {
        radius = 0;
      };
    };
  };
}
