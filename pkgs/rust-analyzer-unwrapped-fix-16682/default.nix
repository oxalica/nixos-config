{ rust-analyzer-unwrapped }:
rust-analyzer-unwrapped.overrideAttrs (old: {
  patches = old.patches or [ ] ++ [
    ./0001-fix-Don-t-panic-on-synthetic-syntax-in-inference-dia.patch
  ];
})
