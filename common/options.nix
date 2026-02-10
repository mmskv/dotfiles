{lib, ...}: {
  options.custom = {
    desktop.enable = lib.mkEnableOption "is desktop";
    work.enable = lib.mkEnableOption "configuration for work";
  };
}
