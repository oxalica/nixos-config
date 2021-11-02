# https://github.com/nix-community/home-manager/pull/2439
{ lib, config, pkgs, ... }:
with lib;
{
  options = {
    xdg.stateHome = mkOption {
      type = types.path;
      defaultText = "~/.local/state";
      default = "${config.home.homeDirectory}/.local/state";
      apply = toString;
      description = ''
        Absolute path to directory holding application states.
      '';
    };
  };

  config = {
    assertions = [
      {
        assertion = config.xdg.stateHome == "${config.home.homeDirectory}/.local/state";
        message = "xdg.stateHome modification is not supported, waiting for https://github.com/nix-community/home-manager/pull/2439";
      }
    ];
  };
}
