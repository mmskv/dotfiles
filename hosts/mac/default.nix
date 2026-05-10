{
  pkgs,
  sec,
  ...
}: {
  imports = [
    ../../common/mac
  ];

  system.primaryUser = sec.mac.user;

  users.users.${sec.mac.user} = {
    home = sec.mac.homeDir;
    shell = pkgs.fish;
  };

  nix.settings.trusted-users = [sec.mac.user];

  system.stateVersion = 5;
}
