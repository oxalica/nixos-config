{ cargo-machete, fetchpatch }:
cargo-machete.overrideAttrs (old: {
  patches = old.patches or [ ] ++ [
    # https://github.com/bnjbvr/cargo-machete/pull/134
    (fetchpatch {
      url = "https://github.com/oxalica/cargo-machete/commit/c70efceea0ee894c692da1e443da5da15703e609.patch";
      hash = "sha256-q7Pd0MTQTs6h1hlyt2l1WwKadKpphXNVnGByQutoTq8=";
      excludes = [ "CHANGELOG.md" ];
    })
  ];
})
