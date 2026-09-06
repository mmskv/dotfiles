{desktopTheme, ...}: let
  inherit (desktopTheme.colors) document;
in {
  programs.zathura = {
    enable = true;
    options = {
      recolor-darkcolor = "#${document.foreground}";
      recolor-lightcolor = "#${document.background}";
      recolor = true;
      selection-clipboard = "clipboard";
    };
  };
}
