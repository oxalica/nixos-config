{ pkgs, ... }:

{
  environment.systemPackages = [ pkgs.git ];

  environment.etc."gitconfig".text = ''
    [alias]
    br=branch
    cmt=commit
    co=checkout
    cp=cherry-pick
  '';
}
