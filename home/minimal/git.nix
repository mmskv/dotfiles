{
  sec,
  lib,
  pkgs,
  ...
}: {
  programs.git = {
    enable = true;

    settings = {
      user = sec.user;

      status.useBuiltinFSMonitor = true;

      core = {
        fsmonitor = true;
        preloadIndex = true;
        untrackedCache = true;
      };

      alias = {
        s = "status";
        co = "checkout";
        cob = "checkout -b";
        br = "branch --format='%(HEAD) %(color:yellow)%(refname:short)%(color:reset) - %(contents:subject) %(color:green)(%(committerdate:relative)) [%(authorname)]' --sort=-committerdate";
        l = "log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)' --all";
        c = "commit -v";
      };

      push.autoSetupRemote = true;
      init.defaultBranch = "master";
      url."ssh://git@github.com/".insteadOf = "https://github.com/";
    };

    includes = lib.optionals pkgs.stdenv.isDarwin [
      {
        condition = "gitdir:~/work/";

        contents = sec.git.work;
      }
    ];
  };

  programs.difftastic = {
    enable = true;
    git.enable = true;
    options = {
      background = "dark";
      display = "side-by-side";
    };
  };
}
