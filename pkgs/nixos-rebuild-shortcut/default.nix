{
  lib,
  stdenv,
  runCommand,
  runtimeShell,
  hostname,
  coreutils,
  nixos-rebuild-ng,
  git,
  nix,
  nix-output-monitor,
  ...
}:
runCommand "nixos-rebuild-shortcut"
  {
    preferLocalBuild = true;
    allowSubstitutes = false;

    inherit runtimeShell;
    paths = lib.escapeShellArg (
      lib.makeBinPath [
        coreutils
        git
        hostname
        nix
        nix-output-monitor
        nixos-rebuild-ng
      ]
    );
  }
  ''
    mkdir -p $out/bin
    substituteAll ${./nixos.sh} $out/bin/nixos
    chmod +x $out/bin/nixos
    ${stdenv.shellDryRun} $out/bin/nixos
  ''
