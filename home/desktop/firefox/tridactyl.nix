{
  lib,
  sec,
  ...
}: let
  ch = "25.11";
in {
  xdg.configFile."tridactyl/tridactylrc".text = ''
    set searchurls.rust https://doc.rust-lang.org/std/index.html?search=
    set searchurls.gh https://github.com/search?q=
    set searchurls.pkgs https://search.nixos.org/packages?channel=${ch}&sort=relevance&type=packages&query=
    set searchurls.options https://search.nixos.org/options?channel=${ch}&from=0&size=50&sort=relevance&type=packages&query=
    set searchurls.home https://home-manager-options.extranix.com/?release=release-${ch}&query=

    autocmd DocStart ^https://monkeytype.com mode ignore
    autocmd DocLoad ^https://monkeytype.com mode ignore
    autocmd DocStart ^https://github.com mode ignore
    autocmd DocLoad ^https://github.com mode ignore

    ${lib.concatStringsSep "\n"
      (lib.mapAttrsToList (key: url: "quickmark ${key} ${url}") sec.tridactyl.quickmarks)}

    ${lib.concatStringsSep "\n"
      (map (url: "bmark ${url}") sec.tridactyl.bmarks)}
  '';
}
