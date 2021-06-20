{ pkgs, ... }:
let
  coc-settings = {
    "rust-analyzer.server.path" = "${pkgs.rust-analyzer}/bin/rust-analyzer";
  };

  coc-config-home = pkgs.writeTextFile {
    name = "coc-config-home";
    destination = "/coc-settings.json";
    text = builtins.toJSON coc-settings;
  };
in
{
  programs.vim = {
    enable = true;
    extraConfig = ''
      source ${./init.vim}

      " Plugin settings

      " coc-nvim
      let g:coc_config_home='${coc-config-home}'
      inoremap <silent><expr> <c-@> coc#refresh()
      inoremap <silent><expr> <cr> pumvisible() ? coc#_select_confirm() : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

      " coc-rust-analyzer
      let g:rustfmt_autosave = 1

      " nerdcommenter
      let g:NERDSpaceDelims = 1
      let g:NERDDefaultAlign = 'left'
      let g:NERDCommentEmptyLines = 1

      " vim-sandwich
      runtime START **/sandwich/keymap/surround.vim
    '';

    plugins = with pkgs.vimPlugins; [
      easymotion
      nerdcommenter
      rust-vim
      vim-cursorword
      vim-gitgutter
      vim-nix
      vim-sandwich
      vim-toml

      coc-nvim
      coc-rust-analyzer

      (pkgs.vimUtils.buildVimPlugin {
        name = "lilypink";
        src = ./lilypink;
      })

      (pkgs.callPackage ./fcitx5-vim {})
    ];
  };
}
