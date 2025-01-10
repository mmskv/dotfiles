{ pkgs, ... }:
{
  programs.fish = {
    enable = true;

    shellAliases = {
      l = "ls -lh --group-directories-first --color=always";
      la = "ls -a --color=always";
      ll = "ls -alh --color=always";
      grep = "grep --color=auto -i";
      wgp = "wgetpaste -X -s dpaste";
      cp = "cp -iv";
      mv = "mv -iv";
      rm = "rm -v";
      ip = "ip -c";
      rebuild = "nixos-rebuild switch --use-remote-sudo";
    };

    loginShellInit = ''
      if test (tty) = /dev/tty1 && uwsm check may-start
        exec uwsm start hyprland-uwsm.desktop
      end
    '';

    interactiveShellInit = ''
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

      set fish_cursor_default block
      set fish_cursor_insert line
      set fish_cursor_replace_one underscore
      set fish_cursor_visual block

      bind -M insert \cp up-or-search
      bind -M insert \cn down-or-search
      bind -M insert \cY accept-autosuggestion
      bind -M visual \x20y fish_clipboard_copy # leader yank like vim

      set pure_show_prefix_root_prompt true
      set pure_enable_nixdevshell true
      set pure_symbol_nixdevshell_prefix 
      set pure_color_success brwhite
      set pure_color_command_duration magenta
      set pure_enable_container_detection false
    '';

    plugins = [
      {
        name = "pure";
        src = pkgs.fetchFromGitHub {
          owner = "pure-fish";
          repo = "pure";
          rev = "28447d2e7a4edf3c954003eda929cde31d3621d2";
          sha256 = "sha256-8zxqPU9N5XGbKc0b3bZYkQ3yH64qcbakMsHIpHZSne4=";
        };
      }
    ];
  };

  home.packages = with pkgs; [
    fishPlugins.done
    fishPlugins.fzf-fish
    fishPlugins.hydro
    fishPlugins.grc
  ];
}
