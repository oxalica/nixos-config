# FIXME: https://github.com/NixOS/nixpkgs/pull/196390
{ lib, stdenv, fetchFromGitHub, rustPlatform, pkg-config, openssl, nix-update-script, callPackage }:
rustPlatform.buildRustPackage rec {
  pname = "cargo-asm";
  version = "0.1.24";

  src = fetchFromGitHub {
    owner = "pacak";
    repo = "cargo-show-asm";
    rev = version;
    hash = "sha256-ahkKUtg5M88qddzEwYxPecDtBofGfPVxKuYKgmsbWYc=";
  };

  cargoHash = "sha256-S7OpHNjiTfQg7aPmHEx6Q/OV5QA9pB29F3MTIeiLAXg=";

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ openssl ];

  postInstall = ''
    mkdir -p $out/share/{bash-completion/completions,fish/vendor_completions.d,zsh/site-functions}
    $out/bin/cargo-asm --bpaf-complete-style-bash >$out/share/bash-completion/completions/cargo-asm
    $out/bin/cargo-asm --bpaf-complete-style-fish >$out/share/fish/vendor_completions.d/cargo-asm.fish
    $out/bin/cargo-asm --bpaf-complete-style-zsh >$out/share/zsh/site-functions/_cargo-asm
  '';

  meta = with lib; {
    description = "Cargo subcommand showing the assembly, LLVM-IR and MIR generated for Rust code";
    homepage = "https://github.com/pacak/cargo-show-asm";
    license = with licenses; [ asl20 mit ];
    maintainers = with maintainers; [ oxalica ];
  };
}
