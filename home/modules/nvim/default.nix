{ lib, pkgs, inputs, my, ... }:
let
  inherit (my.pkgs) tree-sitter-bash tree-sitter-nix;

  treesitterPlugins = ps: with ps; [
    tree-sitter-agda
    tree-sitter-bash
    tree-sitter-beancount
    tree-sitter-c
    tree-sitter-clojure
    tree-sitter-cmake
    tree-sitter-commonlisp
    tree-sitter-cpp
    tree-sitter-css
    tree-sitter-dockerfile
    tree-sitter-glsl
    tree-sitter-go
    tree-sitter-gomod
    tree-sitter-haskell
    tree-sitter-html
    tree-sitter-java
    tree-sitter-javascript
    tree-sitter-json
    tree-sitter-latex
    tree-sitter-llvm
    tree-sitter-lua
    tree-sitter-make
    # tree-sitter-markdown # Highly broken
    tree-sitter-nix
    tree-sitter-perl
    tree-sitter-python
    tree-sitter-query
    tree-sitter-regex
    tree-sitter-rst
    tree-sitter-rust
    tree-sitter-toml
    tree-sitter-tsx
    tree-sitter-typescript
    tree-sitter-vim
    tree-sitter-yaml
  ];

  vimPlugins = pkgs.vimPlugins // {
    nvim-treesitter = (pkgs.vimPlugins.nvim-treesitter.withPlugins treesitterPlugins).overrideAttrs (old: {
      postInstall = old.postInstall or "" + ''
        for x in highlights locals injections indents; do
          cp -f ${tree-sitter-nix}/queries/nvim-$x.scm $out/queries/nix/$x.scm
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
