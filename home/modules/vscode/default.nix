{ lib, pkgs, ... }:

{
  programs.vscode = {
    enable = true;
    package = pkgs.vscodium;
    userSettings = import ./settings.nix { inherit pkgs; };

    extensions = with pkgs.vscode-extensions; [
      bbenoist.nix
      dbaeumer.vscode-eslint
      eamodio.gitlens
      justusadam.language-haskell
      matklad.rust-analyzer
      ms-python.python
      ms-vscode-remote.remote-ssh
      ms-vscode.cpptools
      serayuzgur.crates
      vadimcn.vscode-lldb
      vscodevim.vim
    ] ++ import ./market-extensions.nix {
      inherit (pkgs.vscode-utils) extensionFromVscodeMarketplace;
    };
  };
}
