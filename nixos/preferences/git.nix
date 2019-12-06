{ pkgs, ... }:

{
  environment.systemPackages = [ pkgs.git ];

  environment.etc."gitconfig".text = ''
    [alias]
    st = status
    br = branch
    cmt = commit
    co = checkout
    cp = cherry-pick

    [pager]
    branch = less -RF
  '';
}
