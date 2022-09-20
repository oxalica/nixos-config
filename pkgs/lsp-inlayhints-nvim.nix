# FIXME: https://github.com/NixOS/nixpkgs/pull/191994
{ source, vimUtils }:
vimUtils.buildVimPlugin {
  name = source.pname;
  inherit (source) version src;
}
