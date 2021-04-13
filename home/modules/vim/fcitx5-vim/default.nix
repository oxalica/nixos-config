{ vimUtils, fcitx5, breakpointHook }:
vimUtils.buildVimPluginFrom2Nix {
  pname = "fcitx5";
  version = "dev";
  src = ./.;
  # nativeBuildInputs = [ breakpointHook ];
  postFixup = ''
    substituteInPlace "$out/share/vim-plugins/fcitx5-dev/plugin/fcitx5.vim" \
      --replace "@fcitx5@" "${fcitx5}"
  '';
}

