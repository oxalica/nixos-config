{ lib, pkgs, inputs, my, ... }:
let
  treesitterPlugins = ps:
    (lib.filter (p: lib.isDerivation p && p.pname != "nix-grammar")
      (lib.attrValues ps)) ++
    [ my.pkgs.tree-sitter-nix ];

  vimPlugins = pkgs.vimPlugins // {
    nvim-treesitter = (pkgs.vimPlugins.nvim-treesitter.withPlugins treesitterPlugins).overrideAttrs (old: {
      postInstall = old.postInstall or "" + ''
        rm $out/queries/nix/*.scm
        for x in highlights locals injections indents; do
          cp -f ${my.pkgs.tree-sitter-nix}/queries/nvim-$x.scm $out/queries/nix/$x.scm
        done
      '';
    });

    nvim-treesitter-textobjects = pkgs.vimPlugins.nvim-treesitter-textobjects.overrideAttrs (old: {
      postInstall = old.postInstall or "" + ''
        rm -r $out/queries/nix
      '';
    });
  };

  vimrc = builtins.readFile ./vimrc.vim;
  plugins =
    map (x: vimPlugins.${lib.elemAt x 0})
      (lib.filter (x: lib.isList x)
        (builtins.split ''" plugin: ([A-Za-z_-]+)'' vimrc));

  # https://github.com/neoclide/coc.nvim/blob/28e0edd7818ad1b202680f4d1d814435488d0b8e/data/schema.json
  cocSettings = {
    "coc.preferences.currentFunctionSymbolAutoUpdate" = true;
    "coc.preferences.extensionUpdateCheck" = "never";
    "diagnostic.errorSign" = "⮾ ";
    "diagnostic.hintSign" = "💡";
    "diagnostic.infoSign" = "🛈 ";
    "diagnostic.warningSign" = "⚠";
    "links.tooltip" = true;
    "semanticTokens.enable" = true;
    "suggest.noselect" = true;

    "[rust]"."coc.preferences.formatOnSave" = true;

    languageserver = {
      lua = {
        command = "${pkgs.sumneko-lua-language-server}/bin/lua-language-server";
        filetypes = [ "lua" ];
        rootPatterns = [ ".git" ];
      };

      nix = {
        # Use from PATH to allow overriding.
        command = "nil";
        filetypes = [ "nix" ];
        rootPatterns = [ "flake.nix" ".git" ];
        settings.nil = {
          formatting.command = [ "${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt" ];
        };
      };

      python = {
        command = "${pkgs.pyright}/bin/pyright-langserver";
        args = [ "--stdio" ];
        filetypes = [ "python" ];
        rootPatterns = [ "pyproject.toml" "setup.py" "setup.cfg" "requirements.txt" "Pipfile" "pyrightconfig.json" ];
      };

      rust = {
        command = "${pkgs.rust-analyzer}/bin/rust-analyzer";
        filetypes = [ "rust" ];
        rootPatterns = [ "rust-project.json" "Cargo.lock" ".git" ];
        # https://github.com/rust-lang/rust-analyzer/blob/master/crates/rust-analyzer/src/config.rs
        settings.rust-analyzer = {
          checkOnSave.command = "clippy";
          imports.granularity.group = "module";
          semanticHighlighting.strings.enable = false;
        };
      };

      sh = {
        command = "${pkgs.nodePackages.bash-language-server}/bin/bash-language-server";
        args = [ "start" ];
        filetypes = [ "sh" "bash" ];
        # https://github.com/bash-lsp/bash-language-server/blob/51447c84c5316f869d6f4409d64ab0be0753c5bb/server/src/config.ts
        env = {
          GLOB_PATTERN = "**/*@(.sh|.bash)";
          HIGHLIGHT_PARSING_ERRORS = true;
          SHELLCHECK_PATH = "${pkgs.shellcheck}/bin/shellcheck";
        };
      };

      typescript = {
        command = "${pkgs.nodePackages.typescript-language-server}/bin/typescript-language-server";
        args = [ "--stdio" "--tsserver-path=${pkgs.nodePackages.typescript}/bin/tsserver" ];
        filetypes = [ "typescript" "javascript" ];
        rootPatterns = [ "package.json" "tsconfig.json" "jsconfig.json" ".git" ];
      };
    };
  };

in
{
  programs.neovim = {
    enable = true;
    withRuby = false;
    inherit plugins;
    extraConfig = vimrc;

    coc = {
      enable = true;
      settings = cocSettings;
    };
  };

  home.sessionVariables.EDITOR = "nvim";

  home.packages = with pkgs; [ nil ];
}
