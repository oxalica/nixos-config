{ nix-output-monitor, fetchpatch }:
nix-output-monitor.overrideAttrs (old: {
  pname = "nix-output-monitor-fix-trace";

  patches = old.patches or [] ++ [
    (fetchpatch {
      url = "https://github.com/maralorn/nix-output-monitor/commit/738f445082d6d5c8f96701ccd1fe1136a7a47715.patch";
      hash = "sha256-6uq55PmenrrqVx+TWCP2AFlxlZsYu4NXRTTKYIwRdY4=";
    })
  ];
})
