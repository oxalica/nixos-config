{ ... }:
{
  nixpkgs.overlays = [
    (self: super: {
      vim-oxa = super.vim_configurable.customize {
        name = "vim";

        vimrcConfig.packages.myVimPackage = with self.vimPlugins; {
          start = [
            vim-surround
            vim-nix
          ];
        };

        vimrcConfig.customRC = builtins.readFile ./vim.vim;
      };
    })
  ];
}
