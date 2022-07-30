{ lib, runCommandNoCC, fetchFromGitHub }:
runCommandNoCC "rime_latex" {
  version = "unstable-2022-01-21";
  src = fetchFromGitHub {
    owner = "shenlebantongying";
    repo = "rime_latex";
    rev = "3fbf0e02a264f56fc32ac0628f62033723f8a0e7";
    hash = "sha256-Y7CBVhqL/Gx7ZB0xKdhOgvGogDAyRq0ibioq71Xu4/M=";
  };
  meta.license = with lib.licenses; [ gpl3Only ];
} ''
  install -Dm444 -t $out/share/rime-data $src/latex.{dict,schema}.yaml
''
