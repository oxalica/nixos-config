{ lib, rustPlatform, linuxHeaders }:
rustPlatform.buildRustPackage {
  name = "ublk-allow-unprivileged";
  src = ./.;
  cargoLock.lockFile = ./Cargo.lock;

  nativeBuildInputs = [ rustPlatform.bindgenHook ];
  buildInputs = [ linuxHeaders ];

  postInstall = ''
    mv $out/bin $out/libexec
    binPath="$out/libexec/ublk-allow-unprivileged"

    mkdir -p $out/etc/udev/rules.d
    cat <<EOF >$out/etc/udev/rules.d/99-ublk-allow-unprivileged.rules
    KERNEL=="ublk-control", MODE="0666", OPTIONS+="static_node=ublk-control"
    ACTION=="add",KERNEL=="ublk[bc]*",RUN+="$binPath %k"
    EOF
  '';

  meta.license = with lib.licenses; [ mit asl20 ];
}
