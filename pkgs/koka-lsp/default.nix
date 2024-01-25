# See `src/main.rs` for more details.
{ lib, rustPlatform }:
rustPlatform.buildRustPackage rec {
  name = "koka-lsp";
  src = ./.;
  cargoLock.lockFile = ./Cargo.lock;
  meta.license = with lib.licenses; [ mit asl20 ];
  meta.description = "Wrapper for koka's builtin LSP to work under stdio";
  meta.mainProgram = name;
}
