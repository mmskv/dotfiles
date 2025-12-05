{
  pkgs,
  lib,
  config,
  sec,
  ...
}: {
  programs.bash.enable = true;

  programs.fish = {
    enable = true;

    shellAliases = {
      l = "eza -l --group-directories-first";
      ls = "eza";
      la = "eza -a";
      ll = "eza -al";
      lg = "eza -al --git";
      cat = "bat";
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

        # no override for aliases
        set -U grc_plugin_ignore_execs ls
        set -U grc_plugin_ignore_execs cat

        function fish_should_add_to_history
            string match -qr '^export\s+VAULT_TOKEN' -- $argv
            and return 1

            string match -qr '^set\s+.*VAULT_TOKEN' -- $argv
            and return 1

            return 0
        end

        function _update_vault_prompt --on-event fish_postexec --on-variable PWD --on-variable VAULT_ADDR --on-variable VAULT_TOKEN
          if test -n "$VAULT_ADDR"
            string match -q "$HOME/work*" "$PWD"; or begin set -e VAULT_PROMPT_STR; return; end

            set -l v_label "Vault"
            switch "$VAULT_ADDR"
              ${lib.concatStrings (lib.mapAttrsToList (name: value: ''
            case "*${value}*"
              set v_label "${name}"
          '')
          sec.work.vault.servers)}
            end

            if test -n "$VAULT_TOKEN"
               set -gx VAULT_PROMPT_STR "$v_label+"
            else
               set -gx VAULT_PROMPT_STR "$v_label-"
            end
          else
            set -e VAULT_PROMPT_STR
          end
        end
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
          "\${env_var.VAULT_PROMPT_STR}"
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

        env_var.VAULT_PROMPT_STR = {
          variable = "VAULT_PROMPT_STR";
          style = "bold purple";
          format = "[$env_value]($style) ";
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

  programs.eza = {
    enable = true;
    colors = "auto";
    enableFishIntegration = true;
    theme = pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/eza-community/eza-themes/refs/heads/main/themes/rose-pine-moon.yml";
      sha256 = "sha256-F96YJctnXUXpvSwwf0cjlXcKzVumFH06BoC26sosGXY=";
    };
  };

  programs.bat = {
    enable = true;
    config = {
      style = "plain";
      wrap = "never";
      paging = "never";
    };
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
