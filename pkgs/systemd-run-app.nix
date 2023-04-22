# From https://github.com/NickCao/flakes/blob/67fac11e53d6ee0ff27a90fcaf9cab2e59a935a6/pkgs/systemd-run-app/default.nix
{ writeShellApplication, coreutils }:
writeShellApplication {
  name = "systemd-run-app";
  text = ''
    name="$(/run/current-system/systemd/bin/systemd-escape "$(${coreutils}/bin/basename "$1")")"
    exec /run/current-system/systemd/bin/systemd-run \
      --user \
      --scope \
      --unit="app-$name-$(printf %04x $RANDOM)" \
      --slice=app \
      --same-dir \
      --collect \
      --property PartOf=graphical-session.target \
      --property After=graphical-session.target \
      -- "$@"
  '';
}
