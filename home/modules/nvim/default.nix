{ lib, pkgs, inputs, my, ... }:
let
  treesitterPlugins = ps:
    (lib.filter (p: lib.isDerivation p && p.pname != "nix-grammar")
      (lib.attrValues ps)) ++
    [ my.pkgs.tree-sitter-nix ];

  vimPlugins = pkgs.vimPlugins // {
    nvim-treesitter = (pkgs.vimPlugins.nvim-treesitter.withPlugins treesitterPlugins).overrideAttrs (old: {
      postInstall = old.postInstall or "" + ''
        for x in highlights locals injections indents; do
          cp -f ${my.pkgs.tree-sitter-nix}/queries/nvim-$x.scm $out/queries/nix/$x.scm
        done
      '';
    });
  };

  vimrc = builtins.readFile ./vimrc.vim;
  plugins =
    map (x: vimPlugins.${lib.elemAt x 0})
      (lib.filter (x: lib.isList x)
        (builtins.split ''" plugin: ([A-Za-z_-]+)'' vimrc));

in
{
  programs.neovim = {
    enable = true;
    withRuby = false;
    inherit plugins;
    extraConfig = vimrc;
  };

  home.sessionVariables.EDITOR = "nvim";

  # Use default LSP `cmd` from PATH to allow overriding.
  home.packages = with pkgs; [
    pyright
    rust-analyzer
    nil
    nodePackages.typescript
    nodePackages.typescript-language-server
  ];
}
