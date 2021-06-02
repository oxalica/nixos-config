{ pkgs, ... }:
{
  programs.vim = {
    enable = true;
    extraConfig = ''
      source ${./init.vim}

      let g:rustfmt_autosave = 1
    '';

    plugins = with pkgs.vimPlugins; [
      easymotion
      rust-vim
      vim-cursorword
      vim-gitgutter
      vim-nix
      vim-surround
      vim-toml

      (pkgs.vimUtils.buildVimPlugin {
        name = "lilypink";
        src = ./lilypink;
      })

      (pkgs.callPackage ./fcitx5-vim {})
    ];
  };
}
