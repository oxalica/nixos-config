{ lib, pkgs, ... }:
{
  home.sessionVariables = {
    # Rust and python outputs.
    PATH = "$PATH\${PATH:+:}$HOME/.cargo/bin:$HOME/.local/bin";
  };

  programs.zsh = {
    enable = true;

    enableCompletion = true;
    enableAutosuggestions = true;

    history = {
      ignoreDups = true;
      ignoreSpace = true;
      share = false;
    };

    shellAliases = {
      g = "git";
      l = "exa --classify";
      ls = "exa";
      t = "bsdtar";

      py = "python";
      rm = "echo \"No, you shouldn't rm\"";
    };

    oh-my-zsh = {
      enable = true;
      theme = "avit";
      plugins = [
        "z"
        "git"
      ];
    };
  };

  home.packages = let
    flake-zsh-completion = pkgs.runCommand "flake-zsh-completion" {} ''
      mkdir -p $out/share/zsh/site-functions
      cp ${pkgs.nixFlakes.src}/misc/zsh/completion.zsh $out/share/zsh/site-functions/_nix
    '';
  in [ (lib.hiPrio flake-zsh-completion) ];
}
