{
  lib,
  config,
  pkgs,
  my,
  ...
}:
let
  inherit (pkgs) vimPlugins;

  vimrc = builtins.readFile ./vimrc.vim;

  vimrc' =
    builtins.replaceStrings [ "@fcitx5-remote@" ] [ "${lib.getBin pkgs.fcitx5}/bin/fcitx5-remote" ]
      vimrc;

  plugins =
    map (x: vimPlugins.${lib.elemAt x 0}) (
      lib.filter (x: lib.isList x) (builtins.split ''" plugin: ([A-Za-z_-]+)'' vimrc)
    )
    ++ cocPlugins
    ++ [
      (pkgs.runCommandNoCC "koka-vim" { } ''
        cp -r ${pkgs.koka.src}/support/vim $out
      '')
    ];

  cocPlugins = with vimPlugins; [
    coc-eslint
    coc-json
    coc-pyright
    coc-rust-analyzer
    coc-sumneko-lua
    coc-tsserver
  ];

  cocSettings = {
    "coc.preferences.currentFunctionSymbolAutoUpdate" = true;
    "coc.preferences.extensionUpdateCheck" = "never";
    "diagnostic.errorSign" = "⮾ ";
    "diagnostic.hintSign" = "💡";
    "diagnostic.infoSign" = "🛈 ";
    "diagnostic.warningSign" = "⚠";
    "links.tooltip" = true;
    "semanticTokens.enable" = true;
    "workspace.ignoredFolders" = [
      "${config.xdg.cacheHome}/cargo/**"
      "/nix/store/**"
    ];

    "[rust]"."coc.preferences.formatOnSave" = true;

    "rust-analyzer.updates.checkOnStartup" = false;
    "rust-analyzer.server.path" = "rust-analyzer"; # Use relative path, so it prefers direnv if possible.
    "rust-analyzer.check.command" = "clippy";
    "rust-analyzer.imports.granularity.group" = "module";
    "rust-analyzer.semanticHighlighting.strings.enable" = false;
    "rust-analyzer.inlayHints.parameterHints.enable" = false;

    "sumneko-lua.checkUpdate" = false;
    # https://github.com/xiyaowong/coc-sumneko-lua/issues/22#issuecomment-1252284377
    "sumneko-lua.serverDir" = "${pkgs.sumneko-lua-language-server}/share/lua-language-server";
    "Lua.misc.parameters" = [
      "--metapath=${config.xdg.cacheHome}/sumneko_lua/meta"
      "--logpath=${config.xdg.cacheHome}/sumneko_lua/log"
    ];

    languageserver = {
      nix = {
        # Use from PATH to allow overriding.
        command = "nil";
        filetypes = [ "nix" ];
        rootPatterns = [
          "flake.nix"
          ".git"
        ];
        settings.nil = { };
      };
      koka = {
        filetypes = [ "koka" ];
        command = "koka";
        args = [
          "--language-server"
          "--lsstdio"
        ];
      };
    };
  };

in
{
  programs.neovim = {
    enable = true;
    withRuby = false;
    inherit plugins;
    extraConfig = vimrc';

    coc = {
      enable = true;
      settings = cocSettings;
    };
  };

  home.sessionVariables.EDITOR = "nvim";

  home.packages = with pkgs; [
    nil
    rust-analyzer
    watchman # Required by coc.nvim for file watching.
    fzf
    bat # Required by fzf.vim.
    nodejs # FIXME: coc.nvim cannot find node executable
  ];

  # Forbid some LSP (eg. pyright) from watching big directories.
  home.file.".watchman.json".text = builtins.toJSON {
    ignore_dirs = [
      "/"
      "/nix"
      "/nix/store"
      "${config.home.homeDirectory}/storage"
      "${config.home.homeDirectory}/archive"
    ];
  };
}
