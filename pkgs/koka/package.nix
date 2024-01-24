{ stdenv
, pkgsHostTarget
, cmake
, makeWrapper
, mkDerivation
, fetchFromGitHub
, alex
, lib
, hpack
, aeson
, array
, async
, base
, bytestring
, co-log-core
, cond
, containers
, directory
, isocline
, lens
, lsp
, mtl
, network
, network-simple
, parsec
, process
, text
, text-rope
, time
, fetchpatch
}:

let
  version = "3.0.1";
  src = fetchFromGitHub {
    owner = "koka-lang";
    repo = "koka";
    rev = "v${version}";
    sha256 = "sha256-fLk4XokoKRQTLlBfpc7JZ3LUiYSIUZTBLyxTsCCXW7Q=";
    fetchSubmodules = true;
  };
  kklib = stdenv.mkDerivation {
    pname = "kklib";
    inherit version;
    src = "${src}/kklib";
    nativeBuildInputs = [ cmake ];
    outputs = [ "out" "dev" ];
    postInstall = ''
      mkdir -p ''${!outputDev}/share/koka/v${version}
      cp -a ../../kklib ''${!outputDev}/share/koka/v${version}
    '';
  };
  inherit (pkgsHostTarget.targetPackages.stdenv) cc;
  runtimeDeps = [
    cc
    cc.bintools.bintools
    pkgsHostTarget.gnumake
    pkgsHostTarget.cmake
  ];
in
mkDerivation rec {
  pname = "koka";
  inherit version src;
  patches = [
    (fetchpatch {
      url = "https://github.com/koka-lang/koka/commit/9346296a9369f338cc9e8be35550724ec4867943.patch";
      hash = "sha256-87xbWBca34+gNI/f7h0cKaCyP+NLkajWZTO/KCTErfM=";
    })
  ];
  isLibrary = false;
  isExecutable = true;
  libraryToolDepends = [ hpack ];
  executableHaskellDepends = [
    aeson
    array
    async
    base
    bytestring
    co-log-core
    cond
    containers
    directory
    isocline
    lens
    lsp
    mtl
    network
    network-simple
    parsec
    process
    text
    text-rope
    time
    kklib
  ];
  executableToolDepends = [ alex makeWrapper ];
  postInstall = ''
    mkdir -p $out/share/koka/v${version}
    cp -a lib $out/share/koka/v${version}
    ln -s ${kklib.dev}/share/koka/v${version}/kklib $out/share/koka/v${version}
    wrapProgram "$out/bin/koka" \
      --set CC "${lib.getBin cc}/bin/${cc.targetPrefix}cc" \
      --prefix PATH : "${lib.makeSearchPath "bin" runtimeDeps}"
  '';
  doCheck = false;
  prePatch = "hpack";
  description = "Koka language compiler and interpreter";
  homepage = "https://github.com/koka-lang/koka";
  changelog = "${homepage}/blob/master/doc/spec/news.mdk";
  license = lib.licenses.asl20;
}
