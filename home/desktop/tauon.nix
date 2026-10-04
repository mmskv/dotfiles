{pkgs, ...}: {
  home.packages = [
    (pkgs.tauon.overrideAttrs (old: {
      patches = (old.patches or []) ++ [./tauon/keep-album-folders.patch];
      postPatch = old.postPatch or "";
    }))
  ];
}
