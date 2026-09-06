{pkgs, ...}: {
  programs.imv = {
    enable = true;

    settings.binds = {
      # Print the current image.
      "<Ctrl+p>" = ''exec ${pkgs.cups}/bin/lp "$imv_current_file"'';

      # Trashing is recoverable, unlike deleting the file directly.
      "<Ctrl+x>" = ''exec ${pkgs.glib}/bin/gio trash -- "$imv_current_file"; quit'';
      "<Ctrl+Shift+X>" = ''exec ${pkgs.glib}/bin/gio trash -- "$imv_current_file"; close'';

      # Rotate the file itself rather than only changing the viewer transform.
      "<Ctrl+r>" = ''exec ${pkgs.imagemagick}/bin/mogrify -rotate 90 "$imv_current_file"'';

      # Annotate in Satty, saving back to the current image, then close imv.
      "<Ctrl+e>" = ''exec ${pkgs.satty}/bin/satty --filename "$imv_current_file" --output-filename "$imv_current_file" & ; quit'';
    };
  };
}
