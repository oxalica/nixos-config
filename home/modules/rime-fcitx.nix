{
  lib,
  config,
  pkgs,
  ...
}:
let
  toYAML = builtins.toJSON;
  buildDir = "${config.xdg.cacheHome}/fcitx5-rime";
  onChange = ''
    rimeSettingChanged=1
  '';
in
{
  home.activation.setupRimeCacheDirectory =
    lib.hm.dag.entryAfter [ "writeBoundary" "onFilesChange" ]
      ''
        run mkdir -p "${buildDir}"
        if [[ -v rimeSettingChanged ]]; then
          run rm -rf "${buildDir}"/*
        fi
        if [[ -z "$(ls ${buildDir})" ]]; then
          run ${pkgs.qt5.qttools.bin}/bin/qdbus org.fcitx.Fcitx5 /controller org.fcitx.Fcitx.Controller1.SetConfig "fcitx://config/addon/rime/deploy" ""
        fi
      '';

  xdg.dataFile = {
    "fcitx5/rime/build".source = config.lib.file.mkOutOfStoreSymlink buildDir;

    "fcitx5/rime/default.custom.yaml" = {
      inherit onChange;
      text = toYAML {
        patch = {
          "menu/page_size" = 9;
          schema_list = [
            { schema = "double_pinyin"; }
            { schema = "latex"; }
          ];
        };
      };
    };

    "fcitx5/rime/double_pinyin.custom.yaml" = {
      inherit onChange;
      text = toYAML {
        __include = "emoji_suggestion:/";
        "switches/@2/reset" = 1;
      };
    };
  };
}
