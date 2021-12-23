# Reference: https://gitlab.com/NickCao/flakes/-/blob/master/nixos/local/home.nix#L71
{ config, ... }:
{
  home.sessionVariables = {
    HISTFILE = "${config.xdg.stateHome}/bash/history";
    LESSHISTFILE = "${config.xdg.stateHome}/less/history";
    SQLITE_HISTORY = "${config.xdg.stateHome}/sqlite/history";
  };

  # XDG Spec doens't have BIN_HOME yet.
  home.xdg.configFile."go/env".text = ''
    GOPATH=${config.xdg.cacheHome}/go
    GOBIN=${config.homeDirectory}/.local/bin
  '';
}
