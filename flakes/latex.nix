{pkgs}: let
  # Watch and compile LaTeX files in tmux
  latex-watch = pkgs.writers.writeFishBin "latex-watch" ''
    set tex_file $argv[1]
    if test -z "$tex_file"
      set tex_file (ls *.tex | head -n 1)
    end

    # Get absolute paths
    set current_dir (pwd)

    if not ${pkgs.tmux}/bin/tmux has-session -t special 2>/dev/null
      ${pkgs.tmux}/bin/tmux new-session -d -s special
    end

    # First change directory in tmux session
    ${pkgs.tmux}/bin/tmux send-keys -t special "cd $current_dir" C-m

    # Build the command with separate variables for proper Nix expansion
    set entr_cmd "${pkgs.entr}/bin/entr"
    set latexmk_cmd "${pkgs.texlive.combined.scheme-full}/bin/latexmk -pdf -lualatex -use-make -interaction=nonstopmode $tex_file"
    set notify_cmd "${pkgs.hyprland}/bin/hyprctl notify -t 2000 \"LaTeX compilation failed\""

    # Then run the compilation command with properly expanded variables
    ${pkgs.tmux}/bin/tmux send-keys -t special "find . -name '*.tex' -o -name '*.bib' | $entr_cmd -s '$latexmk_cmd || $notify_cmd'" C-m
  '';

  # Open PDF in zathura
  latex-open = pkgs.writers.writeFishBin "latex-open" ''
    set tex_file $argv[1]
    if test -z "$tex_file"
      set tex_file (ls *.tex | head -n 1)
    end

    set pdf_file (echo $tex_file | sed 's/\.tex$/.pdf/')
    set zathura_cmd "${pkgs.zathura}/bin/zathura"

    if test -f $pdf_file
      $zathura_cmd $pdf_file &
    else
      echo "Waiting for PDF..."
      while not test -f $pdf_file
        sleep 1
      end
      $zathura_cmd $pdf_file &
    end
  '';

  # Restart zathura
  latex-restart = pkgs.writers.writeFishBin "latex-restart" ''
    set tex_file $argv[1]
    if test -z "$tex_file"
      set tex_file (ls *.tex | head -n 1)
    end

    set pdf_file (echo $tex_file | sed 's/\.tex$/.pdf/')
    set pkill_cmd "${pkgs.procps}/bin/pkill"
    set zathura_cmd "${pkgs.zathura}/bin/zathura"

    $pkill_cmd -f "zathura.*$pdf_file" || true
    sleep 0.5
    $zathura_cmd $pdf_file &
  '';

  # Start everything
  latex-start = pkgs.writers.writeFishBin "latex-start" ''
    set tex_file $argv[1]
    if test -z "$tex_file"
      set tex_file (ls *.tex | head -n 1)
    end

    latex-watch $tex_file
    sleep 1  # Give compilation a moment to start
    latex-open $tex_file
    if test -n "$EDITOR"
      eval $EDITOR $tex_file
    end
  '';
in
  pkgs.mkShell {
    packages = with pkgs; [
      texlive.combined.scheme-full
      biber
      python3Packages.pygments
      fontconfig
      cmake
      gnumake
      inkscape
      dia
      graphviz
      imagemagick
      ghostscript
      entr
      liberation_ttf
      cm_unicode

      latex-watch
      latex-open
      latex-restart
      latex-start
    ];
  }
