{ config, ... }:
{
  users.users."oxa" = {
    isNormalUser = true;
    uid = 1000;
    group = "oxa";
    extraGroups = [ "wheel" ];
  };
  users.groups."oxa".gid = 1000;
}
