{ lib
, rustPlatform
, fetchFromGitHub
, nix-update-script
}:

rustPlatform.buildRustPackage rec {
  pname = "cargo-machete";
  version = "0.5.0";

  src = fetchFromGitHub {
    owner = "bnjbvr";
    repo = pname;
    rev = "refs/tags/v${version}";
    hash = "sha256-AOi4SnFkt82iQIP3bp/9JIaYiqjiEjKvJKUvrLQJTX8=";
  };

  cargoHash = "sha256-Q/2py0zgCYgnxFpcJD5PfNfIfIEUjtjFPjxDe25f0BQ=";

  # Tests require downloading new crates.
  doCheck = false;

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "Remove unused Rust dependencies with this one weird trick";
    longDescription = ''
      cargo-machete is a Cargo tool that detects unused dependencies in Rust
      projects, in a fast (yet imprecise) way.
    '';
    homepage = "https://github.com/bnjbvr/cargo-machete";
    changelog = "https://github.com/bnjbvr/cargo-machete/blob/v${version}/CHANGELOG.md";
    license = licenses.mit;
    maintainers = with maintainers; [ oxalica ];
  };
}
