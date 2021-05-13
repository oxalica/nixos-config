final: prev:
let
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
in
{
  electrum = wrapElectrum prev.electrum "electrum";
  electron-cash = wrapElectrum prev.electron-cash "electron-cash";
}

