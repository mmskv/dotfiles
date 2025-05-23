{pkgs, ...}: {
  xdg.desktopEntries = {
    neovim-terminal = {
      name = "Neovim (Terminal)";
      comment = "Open files with Neovim in a terminal";
      exec = "${pkgs.alacritty}/bin/alacritty --command ${pkgs.neovim}/bin/nvim %F";
      terminal = false;
      type = "Application";
      icon = "neovim";
      categories = ["Utility" "TextEditor" "TerminalEmulator"];

      mimeType = [
        "text/plain"
        "text/x-chdr"
        "text/x-c++src"
        "text/x-c++hdr"
        "text/x-tex"
        "application/x-zerosize"
        "application/x-shellscript"
        "application/x-python"
        "application/x-yaml"
        "application/octet-stream"
      ];
    };
  };
}
