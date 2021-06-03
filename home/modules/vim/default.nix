{ pkgs, ... }:
{
  programs.vim = {
    enable = true;
    extraConfig = ''
      " Plugin settings
      let g:rustfmt_autosave = 1

      inoremap <silent><expr> <c-@> coc#refresh()
      inoremap <silent><expr> <cr> pumvisible() ? coc#_select_confirm() : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

      let g:NERDCreateDefaultMappings = 0
      let g:NERDSpaceDelims = 1
      let g:NERDDefaultAlign = 'left'
      let g:NERDCommentEmptyLines = 1
      " <c-/>
      nmap  <plug>NERDCommenterToggle
      xmap  <plug>NERDCommenterToggle

      source ${./init.vim}
    '';

    plugins = with pkgs.vimPlugins; [
      easymotion
      nerdcommenter
      rust-vim
      vim-cursorword
      vim-gitgutter
      vim-nix
      vim-surround
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
