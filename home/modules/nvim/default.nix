{ lib, config, pkgs, my, ... }:
let
  inherit (pkgs) vimPlugins;

  vimrc = builtins.readFile ./vimrc.vim;

  vimrc' = builtins.replaceStrings
    ["@fcitx5-remote@"]
    ["${lib.getBin pkgs.fcitx5}/bin/fcitx5-remote"]
    vimrc;

  plugins =
    map (x: vimPlugins.${lib.elemAt x 0})
      (lib.filter (x: lib.isList x)
        (builtins.split ''" plugin: ([A-Za-z_-]+)'' vimrc)) ++
    cocPlugins ++ [
      my.pkgs.koka-vim
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
    "suggest.noselect" = true;
    "workspace.ignoredFolders" = [
      "${config.xdg.cacheHome}/cargo/**"
      "/nix/store/**"
    ];

    "[rust]"."coc.preferences.formatOnSave" = true;

    "pyright.server" = "${lib.getBin pkgs.pyright}/bin/pyright-langserver";

    "rust-analyzer.updates.checkOnStartup" = false;
    "rust-analyzer.server.path" = "${lib.getBin pkgs.rust-analyzer}/bin/rust-analyzer";
    "rust-analyzer.check.command" = "clippy";
    "rust-analyzer.imports.granularity.group" = "module";
    "rust-analyzer.semanticHighlighting.strings.enable" = false;

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
        rootPatterns = [ "flake.nix" ".git" ];
        settings.nil = {
          formatting.command = [ "${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt" ];
        };
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
      package = my.pkgs.coc-nvim-rename-sem-hlgroups;
      settings = cocSettings;
    };
  };

  home.sessionVariables.EDITOR = "nvim";

  home.packages = with pkgs; [
    nil
    watchman # Required by coc.nvim for file watching.
  ];
}
