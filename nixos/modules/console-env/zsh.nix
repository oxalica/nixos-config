{ lib, pkgs, ... }:
{
  programs.zsh = {
    enable = true;

    enableCompletion = true;
    autosuggestions.enable = true;
    setOptions = [ "HIST_IGNORE_DUPS" "HIST_IGNORE_SPACE" "HIST_FCNTL_LOCK" ];
    interactiveShellInit = builtins.readFile ./interactive.zsh;

    ohMyZsh = {
      enable = true;
      theme = "avit";
      plugins = [
        "z"
        "git"
      ];
    };
  };

  environment.shellAliases = {
    # Already set as functions in init script.
    # Need to override oh-my-zsh settings.
    l = "l";
    ls = "ls";
    ll = "ll";

    t = "bsdtar";
  };

  environment.systemPackages = let
    flake-zsh-completion = pkgs.runCommand "flake-zsh-completion" {} ''
      mkdir -p $out/share/zsh/site-functions
      cp ${pkgs.nixFlakes.src}/misc/zsh/completion.zsh $out/share/zsh/site-functions/_nix
    '';
  in [ (lib.hiPrio flake-zsh-completion) ];
}
