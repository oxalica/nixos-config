# https://nixos.org/nixpkgs/manual/#sec-steam-play
{ ... }:
{
  hardware.opengl.driSupport32Bit = true;
  hardware.pulseaudio.support32Bit = true;
}
