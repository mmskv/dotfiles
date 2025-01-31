{pkgs, ...}: {
  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        fields = "exec,filename,name,generic";
        terminal = "''${pkgs.alacritty}/bin/alacritty";
        font = "Fira Mono:size=11";
        anchor = "top";
        icons-enabled = "no";
        lines = 1;
        hide-before-typing = "yes";
        horizontal-pad = 8;
        vertical-pad = 8;
      };
      colors = {
        background = "141414AA";
        text = "C5C8C6FF";
        selection-text = "C5C8C6FF";
        selection-match = "FFFFFFFF";
        border = "9C7446FF";
        selection = "00000000";
        prompt = "8C9440FF";
        input = "8C9440FF";
      };
      border = {
        radius = 0;
      };
    };
  };
}
