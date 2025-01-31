{sec, ...}: {
  programs.git = {
    enable = true;

    inherit (sec.user) userName userEmail;

    aliases = {
      s = "status";
      co = "checkout";
      cob = "checkout -b";
      br = "branch --format='%(HEAD) %(color:yellow)%(refname:short)%(color:reset) - %(contents:subject) %(color:green)(%(committerdate:relative)) [%(authorname)]' --sort=-committerdate";
      l = "log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)' --all";
      c = "commit -v";
    };

    extraConfig = {
      push.autoSetupRemote = true;
      init.defaultBranch = "master";
    };

    difftastic = {
      enable = true;
      background = "dark";
      display = "side-by-side";
    };

    includes = [
      {
        condition = "gitdir:~/work/";

        contents = {
          user = {
            inherit (sec.user.work) name email;
          };
        };
      }
    ];
  };
}
