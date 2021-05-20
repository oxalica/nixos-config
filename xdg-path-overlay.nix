final: prev:
let
  /*
  wrapBinary = pkg: wrapper: final.runCommandLocal pkg.name {
    nativeBuildInputs = [ final.makeWrapper ];
  } ''
    mkdir -p $out
    ln -st $out ${pkg}/*
    rm $out/bin
    mkdir $out/bin
    ${wrapper}
  '';

  wrapElectrum = pkg: binName: wrapBinary pkg ''
    makeWrapper ${pkg}/bin/${binName} $out/bin/${binName} \
      --add-flags "-D" \
      --add-flags '"''${XDG_DATA_HOME:-$HOME/.local/share/${binName}}"' \
  '';
  */

  wrapElectrum = pkg: binName: final.runCommandLocal pkg.name {
    nativeBuildInputs = [ final.makeWrapper final.xorg.lndir ];
  } ''
    mkdir -p $out
    lndir ${pkg} $out

    rm $out/bin/${binName}
    makeWrapper ${pkg}/bin/${binName} $out/bin/${binName} \
      --add-flags "-D" \
      --add-flags '"''${XDG_DATA_HOME:-$HOME/.local/share/${binName}}"' \

    rm $out/share/applications/${binName}.desktop
    sed -E 's#^Exec=.*${binName}#Exec=${binName}#' \
      ${pkg}/share/applications/${binName}.desktop \
      > $out/share/applications/${binName}.desktop \
  '';

in
{
  electrum = wrapElectrum prev.electrum "electrum";
  electron-cash = wrapElectrum prev.electron-cash "electron-cash";
}

