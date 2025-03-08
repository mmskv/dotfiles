{
  pkgs,
  lib,
  config,
  ...
}: {
  programs.bash.enable = true;

  programs.fish = {
    enable = true;

    shellAliases = {
      l = "ls -lh --group-directories-first --color=always";
      la = "ls -a --color=always";
      ll = "ls -alh --color=always";
      grep = "grep --color=auto -i";
      cp = "cp -iv";
      mv = "mv -iv";
      rm = "rm -v";
      ip = "ip -c";
    };

    loginShellInit = lib.mkIf config.common.desktop.enable ''
      if test (tty) = /dev/tty1 && uwsm check may-start
        exec uwsm start hyprland-uwsm.desktop
      end
    '';

    interactiveShellInit =
      # fish
      ''
        set fish_greeting # disable greeting

        set fish_color_command ccccc --bold
        set fish_color_host brcyan
        set fish_color_error e84f4f
        set fish_color_quote green
        set fish_color_param 9dc4c4
        set fish_color_escape 00a6b2
        set fish_color_valid_path brblue
        set fish_color_comment white
        set fish_color_cancel red
        set fish_color_redirection magenta
        set fish_color_keyword bryellow --bold
        set fish_color_end brmagenta --bold
        set fish_color_operator brmagenta --bold
        set fish_pager_color_progress brwhite --background=black
        set fish_pager_color_selected_background -b black
        set fish_pager_color_description 'B3A06D'  'yellow'

        set fish_key_bindings fish_vi_key_bindings
        fzf_configure_bindings --directory=\ct --git_log=\cg --git_status=\cs

        set fish_cursor_default block
        set fish_cursor_insert line
        set fish_cursor_replace_one underscore
        set fish_cursor_visual block

        bind -M insert \cp up-or-search
        bind -M insert \cn down-or-search
        bind -M insert \cY accept-autosuggestion
        bind -M visual \x20y fish_clipboard_copy # leader yank like vim
      '';
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.zoxide = {
    enable = true;
    options = ["--cmd cd"];
    enableFishIntegration = true;
  };

  programs.starship = {
    enable = true;
    enableFishIntegration = true;
    enableTransience = true;

    settings =
      fromTOML (builtins.readFile "${pkgs.starship}/share/starship/presets/nerd-font-symbols.toml")
      // {
        format = lib.concatStrings [
          "$username"
          "$hostname"
          "$directory"
          "$git_branch"
          "$git_commit"
          "$git_state"
          "$git_status"
          "$direnv"
          "$cmd_duration"
          "$line_break"
          #"$python" util https://github.com/starship/starship/issues/5740 is fixed
          "$nix_shell"
          "$character"
        ];
        character.success_symbol = "[❯](bright-white)";
        character.vimcmd_symbol = "[❯](bright-white)";
        directory.style = "blue";
        follow_symlinks = false;

        package.disabled = true;
        jobs.disabled = true;

        directory = {
          truncate_to_repo = false;
          read_only = " ro";
        };

        python = {
          symbol = "";
          format = "[$virtualenv]($style) ";
          style = "bright-black";
        };
        git_branch = {
          format = "[$branch]($style)";
          style = "bright-black";
        };
        git_status = {
          format = "[[($modified)](bright-black)($ahead_behind$stashed)]($style) ";
          style = "cyan";
          modified = "*";
        };
        nix_shell = {
          format = "[$symbol]($style)";
          style = "blue";
          symbol = "󱄅 ";
        };
        cmd_duration = {
          format = "[$duration]($style) ";
          style = "purple";
        };
      };
  };

  programs.tmux = {
    enable = true;
    sensibleOnTop = true;
    shortcut = "a";
    mouse = true;
    keyMode = "vi";
    newSession = true;
    disableConfirmationPrompt = true;
    customPaneNavigationAndResize = true;
    clock24 = true;
    extraConfig =
      # tmux
      ''
        set -g pane-border-style 'fg=red'
        set -g pane-active-border-style 'fg=yellow'
        set -g status-style 'fg=red'

        set -g status-left ""
        set -g status-left-length 10

        set -g status-right-style 'fg=black bg=yellow'
        set -g status-right '%d/%m/%Y %H:%M '
        set -g status-right-length 50

        setw -g window-status-current-style 'fg=black bg=red'
        setw -g window-status-current-format ' #I #W #F '

        setw -g window-status-style 'fg=red bg=black'
        setw -g window-status-format ' #I #[fg=white]#W #[fg=yellow]#F '
        setw -g window-status-bell-style 'fg=yellow bg=red bold'
      '';
  };

  home.packages = with pkgs; [
    (lib.mkIf
      config.common.desktop.enable
      fishPlugins.done)

    fishPlugins.fzf-fish
    fishPlugins.hydro
    fishPlugins.grc
  ];
}
