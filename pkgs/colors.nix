{ source, runCommand, python3 }:
runCommand source.pname {
  inherit (source) src;
  nativeBuildInputs = [ python3 ];
} ''
  install -Dm555 $src $out/bin/colors
  patchShebangs $out/bin
''
