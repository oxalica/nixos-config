{ alacritty, fetchFromGitHub, rustPlatform }:
alacritty.overrideAttrs (old: rec {
  version = "fractional-scale";

  src = fetchFromGitHub {
    owner = "oxalica";
    repo = old.pname;
    rev = "a473de8fb83a3429d31b33db4b971ea09fa2629a";
    hash = "sha256-uGhHUmbYBbdeh465lx6P1i+nSivneMSBLDtkWvMTF2w=";
  };

  cargoDeps = rustPlatform.fetchCargoTarball {
    inherit src;
    hash = "sha256-3xe2vxwSSm+vq/i5ldCK6/sqz8JGwMKDb7gBqoXy7x0=";
  };
})
