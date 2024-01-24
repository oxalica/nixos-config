{ haskell, haskellPackages }:
haskell.lib.compose.justStaticExecutables (haskellPackages.callPackage ./package.nix { })
