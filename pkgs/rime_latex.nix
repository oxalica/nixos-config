{ lib, source, runCommand }:
runCommand "rime_latex" {
  inherit (source) version src;
  meta.license = with lib.licenses; [ gpl3Only ];
} ''
  install -Dm444 -t $out/share/rime-data $src/latex.{dict,schema}.yaml
''
