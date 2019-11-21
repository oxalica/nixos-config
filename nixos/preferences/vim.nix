{ lib, pkgs, ... }:

{
  environment.systemPackages = [ (lib.lowPrio pkgs.vim-oxa) ];
  environment.variables.EDITOR = lib.mkOverride 500 "vim";

  nixpkgs.overlays = [
    (self: super: {
      vim-oxa = super.vim_configurable.customize {
        name = "vim-oxa";

        vimrcConfig.packages.myVimPackage = with self.vimPlugins; {
          start = [
            vim-surround
            vim-nix
          ];
        };

        vimrcConfig.customRC = ''
          set encoding=utf-8 termencoding=utf-8
          set fileencodings=ucs-bom,utf-8,gb18030,latin1

          set tabstop=4 shiftwidth=4 softtabstop=4
          set autoindent smarttab cindent
          set expandtab 
          set backspace=indent,eol,start

          set cursorline
          set number
          set mouse=a

          syntax on
          colorscheme default

          set timeoutlen=500

          nnoremap <c-c> :%y+<cr>
          vnoremap <c-c> :y+<cr>gv

          nnoremap z <esc>:set wrap!<cr>
          nnoremap <cr> <esc>:set hlsearch!<cr>

          cnoremap w!! w !sudo tee % >/dev/null
        '';
      };
    })
  ];
}
