{ lib, pkgs, ... }:

{
  programs.zsh = {
    enable = lib.mkOverride 500 true;

    enableCompletion = true;
    autosuggestions.enable = true;
    setOptions = [ "HIST_IGNORE_DUPS" "HIST_IGNORE_SPACE" "HIST_FCNTL_LOCK" ];
  };
}
