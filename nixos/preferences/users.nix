{ pkgs, ... }:

{
  users = {
    defaultUserShell = pkgs.zsh;

    groups.oxa.gid = 1000;

    users.oxa = {
      isNormalUser = true;
      uid = 1000;
      group = "oxa";
      extraGroups = [ "wheel" ];
    };
  };
}
