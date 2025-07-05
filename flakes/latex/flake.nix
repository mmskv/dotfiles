{
  description = "LaTeX workflow tools";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = {
    self,
    nixpkgs,
  }: let
    supportedSystems = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
    forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

    nixpkgsFor = forAllSystems (system: import nixpkgs {inherit system;});
  in {
    packages = forAllSystems (
      system: let
        pkgs = nixpkgsFor.${system};

        # Watch and compile LaTeX files in tmux
        watch = pkgs.writers.writeFishBin "watch" ''
          set tex_file $argv[1]
          if test -z "$tex_file"
            set tex_file (ls *.tex | head -n 1)
          end

          set current_dir (pwd)

          if not ${pkgs.tmux}/bin/tmux has-session -t special 2>/dev/null
            ${pkgs.tmux}/bin/tmux new-session -d -s special
          end

          ${pkgs.tmux}/bin/tmux send-keys -t special "cd $current_dir" C-m

          set entr_cmd ${pkgs.entr}/bin/entr
          set latexmk_cmd "${pkgs.texlive.combined.scheme-full}/bin/latexmk -pdf -lualatex -use-make -interaction=nonstopmode $tex_file"
          set notify_cmd "${pkgs.hyprland}/bin/hyprctl notify 3 2000 0 \"LaTeX compilation failed\""

          ${pkgs.tmux}/bin/tmux send-keys -t special "find . -name '*.tex' -o -name '*.bib' | $entr_cmd -s '$latexmk_cmd || $notify_cmd'" C-m

          echo "Compilation started in tmux session 'special'"
          echo "Use 'tmux attach -t special' to view"
        '';

        # Open PDF in zathura
        open = pkgs.writers.writeFishBin "open" ''
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

        # Clean build files and restart zathura
        restart = pkgs.writers.writeFishBin "restart" ''
          set tex_file $argv[1]
          if test -z "$tex_file"
            set tex_file (ls *.tex | head -n 1)
          end

          set pdf_file (echo $tex_file | sed 's/\.tex$/.pdf/')
          set pkill_cmd "${pkgs.procps}/bin/pkill"
          set zathura_cmd "${pkgs.zathura}/bin/zathura"
          set latexmk_cmd "${pkgs.texlive.combined.scheme-full}/bin/latexmk"

          # Clean LaTeX build files
          echo "Cleaning LaTeX build files..."
          $latexmk_cmd -C $tex_file

          # Kill zathura and restart
          $pkill_cmd -f "zathura.*$pdf_file" || true

          # Force recompilation by touching the tex file
          touch $tex_file

          echo "Waiting for PDF to rebuild..."
          while not test -f $pdf_file
            sleep 1
          end

          $zathura_cmd $pdf_file &
        '';

        # Start everything
        start = pkgs.writers.writeFishBin "start" ''
          set tex_file $argv[1]
          if test -z "$tex_file"
            set tex_file (ls *.tex | head -n 1)
          end

          ${watch}/bin/watch $tex_file
          sleep 1
          ${open}/bin/open $tex_file

          if test -n "$EDITOR"
            eval $EDITOR $tex_file
          end
        '';
      in {
        inherit watch open restart start;
        default = start;
      }
    );

    devShells = forAllSystems (
      system: let
        pkgs = nixpkgsFor.${system};
      in {
        default = pkgs.mkShell {
          packages = with pkgs; [
            # LaTeX packages
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

            # Dependencies for scripts
            tmux
            zathura
            procps

            # Our custom scripts
            self.packages.${system}.restart
            self.packages.${system}.start
          ];
        };
      }
    );
  };
}
