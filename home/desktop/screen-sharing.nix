{
  desktopTheme,
  inputs,
  pkgs,
  ...
}: let
  inherit (desktopTheme.metrics) sharePicker;
  picker = inputs.hyprland-preview-share-picker.packages.${pkgs.stdenv.hostPlatform.system}.default;
  pickerWrapper = pkgs.writeShellScriptBin "hyprland-preview-share-picker" ''
    exec ${picker}/bin/hyprland-preview-share-picker \
      --logs "''${XDG_RUNTIME_DIR:-/tmp}/hyprland-preview-share-picker.log" \
      "$@"
  '';
  yaml = pkgs.formats.yaml {};
in {
  home.packages = [pickerWrapper];

  xdg.configFile = {
    "hypr/xdph.conf".text = ''
      screencopy {
          allow_token_by_default = false
          custom_picker_binary = ${pickerWrapper}/bin/hyprland-preview-share-picker
      }
    '';

    "hyprland-preview-share-picker/config.yaml".source = yaml.generate "hyprland-preview-share-picker.yaml" {
      stylesheets = [];
      default_page = "outputs";

      window = {
        inherit (sharePicker) height width;
      };

      image = {
        resize_size = sharePicker.previewSize;
        widget_size = sharePicker.widgetSize;
      };

      classes = {
        window = "window";
        image_card = "card";
        image_card_loading = "card-loading";
        image = "image";
        image_label = "image-label";
        notebook = "notebook";
        tab_label = "tab-label";
        notebook_page = "page";
        region_button = "region-button";
        restore_button = "restore-button";
      };

      windows = {
        min_per_row = 3;
        max_per_row = 999;
        clicks = 1;
        spacing = 12;
      };

      outputs = {
        clicks = 1;
        spacing = 6;
        show_label = true;
        respect_output_scaling = true;
      };

      # Uppercase placeholders are relative to the selected output. Absolute
      # coordinates break region sharing on the negatively positioned DP-3.
      region.command = "${pkgs.slurp}/bin/slurp -f '%o@%X,%Y,%W,%H'";

      hide_token_restore = false;
      debug = false;
    };
  };
}
