{
  pkgs-unstable,
  lib,
  ...
}: let
  cmds = before: commands: {inherit before commands;};
  remap = before: after: {inherit before after;};

  k = lib.splitString " ";
in {
  programs.vscode = {
    enable = true;
    package = pkgs-unstable.vscode;
    profiles.default = {
      extensions =
        (with pkgs-unstable.vscode-extensions; [
          mkhl.direnv
          vscodevim.vim
          yzhang.markdown-all-in-one
        ])
        ++ (with pkgs-unstable.vscode-utils; [
          (extensionFromVscodeMarketplace {
            name = "kanagawa-vscode-color-theme";
            publisher = "metaphore";
            version = "0.4.0";
            sha256 = "sha256-B25saMkaTx73uncPtAQFKQfH1j5VMbD67lgJPJcm3vk=";
          })
        ]);
      userSettings = {
        "github.copilot.nextEditSuggestions.enabled" = true;
        "chat.tools.global.autoApprove" = true;
        "chat.tools.terminal.autoApprove" = {
          "docker run" = true;
          "cp" = true;
          "bun" = true;
          "bunx" = true;
          "/.*/" = true;
        };
        "workbench.startupEditor" = "none";
        "workbench.editor.empty.hint" = "hidden";
        "github.copilot.chat.anthropic.tools.websearch.maxUses" = 10;
        "extensions.ignoreRecommendations" = true;
        "chat.agent.maxRequests" = 300;
        "terminal.integrated.profiles.linux" = {
          "Fish Private" = {
            "path" = "fish";
            "args" = ["--private"];
            "icon" = "shield";
          };
        };
        "terminal.integrated.defaultProfile.linux" = "Fish Private";

        # Theme
        "workbench.colorTheme" = "Kanagawa Dragon";

        # Editor
        "editor.renderFinalNewline" = "off";
        "editor.unicodeHighlight.ambiguousCharacters" = false;
        "editor.renderLineHighlight" = "none";
        "editor.fontFamily" = "'FiraMono Nerd Font', monospace";

        # Vim settings
        "vim.leader" = "<space>";
        "vim.handleKeys" = {
          "<C-d>" = true;
          "<C-u>" = true;
          "<C-p>" = false;
        };

        "vim.normalModeKeyBindingsNonRecursive" = [
          # LSP
          (cmds (k "g r") ["editor.action.goToReferences"])
          (cmds (k "g D") ["editor.action.revealDeclaration"])
          (cmds (k "g i") ["editor.action.goToImplementation"])
          (cmds (k "K") ["editor.action.showHover"])
          (cmds (k "<leader> v r n") ["editor.action.rename"])
          (cmds (k "<leader> v c a") ["editor.action.quickFix"])
          (cmds (k "<leader> v d") ["editor.action.marker.next"])
          (cmds (k "[ d") ["editor.action.marker.next"])
          (cmds (k "] d") ["editor.action.marker.prev"])
          (cmds (k "<leader> f") ["editor.action.formatDocument"])
          # Navigation with centering
          (remap (k "n") (k "n z z z v"))
          (remap (k "N") (k "N z z z v"))
          # Fuzzy file finder (like telescope)
          (cmds (k "<C-p>") ["workbench.action.quickOpen"])
          # Tab navigation
          (cmds (k "g 0") ["workbench.action.firstEditorInGroup"])
          (cmds (k "g $") ["workbench.action.lastEditorInGroup"])
          # Copy to system clipboard
          (remap (k "<leader> y") (k "\" + y"))

          # Telescope-style navigation
          (cmds (k "<leader> p p") ["workbench.action.quickOpenPreviousRecentlyUsedEditor"])
          (cmds (k "<leader> p a") ["workbench.action.quickOpen"])
          # <C-p> already mapped to quickOpen for git files
          (cmds (k "<leader> p g") ["git.viewHistory"])
          (cmds (k "<leader> p r") ["workbench.action.findInFiles"])
          (cmds (k "<leader> p s") ["workbench.action.findInFiles"])

          # Current directory variants (these will open with current folder context)
          (cmds (k "<leader> p c a") ["workbench.action.quickOpen"])
          (cmds (k "<leader> p c r") ["workbench.action.findInFiles"])
          (cmds (k "<leader> p c s") ["workbench.action.findInFiles"])
        ];

        "vim.visualModeKeyBindingsNonRecursive" = [
          (cmds (k "J") ["editor.action.moveLinesDownAction"])
          (cmds (k "K") ["editor.action.moveLinesUpAction"])
          # Copy to system clipboard
          (remap (k "<leader> y") (k "\" + y"))
        ];

        "vim.insertModeKeyBindings" = [
          (cmds (k "<C-y>") ["acceptSelectedSuggestion" "editor.action.inlineSuggest.commit"])
          (cmds (k "<C-p>") ["selectPrevSuggestion"])
          (cmds (k "<C-n>") ["selectNextSuggestion"])
        ];
      };
    };
  };
}
