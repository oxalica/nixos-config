{ lib
, rustPlatform
, fetchCrate
, nix-update-script
}:

rustPlatform.buildRustPackage rec {
  pname = "cargo-machete";
  version = "0.5.0";

  src = fetchCrate {
    inherit pname version;
    sha256 = "sha256-fd4jAqdkibAe4yLa/G5Ql3FrN7Yzc9ivnDV6SOscP+4=";
  };

  cargoSha256 = "sha256-Q/2py0zgCYgnxFpcJD5PfNfIfIEUjtjFPjxDe25f0BQ=";

  # FIXME: Figure out why the content of tarball diverges from repo.
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

