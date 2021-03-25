{ lib, pkgs, inputs, ... }:

let
  onChange = ''
    if [[ ! -v fcitxRestarted ]]; then
      fcitxRestarted=1
      # $DRY_RUN_CMD rm -rf "$HOME/.local/share/fcitx5/rime/build"
      $DRY_RUN_CMD "${pkgs.fcitx5}/bin/fcitx5" -dr 2>/dev/null
    fi
  '';

  extraMap = {
    "男" = "♂";
    "女" = "♀";
    "男女" = "⚤ ⚥ ⚦";
    "女女" = "⚢";
    "男男" = "⚣";
    "度" = "°";
    "攝氏度" = "℃";
    "摄氏度" = "℃";
    "華氏度" = "℉";
    "华氏度" = "℉";
    "比特幣" = "₿";
    "比特币" = "₿";
  };

  extraMapFile = pkgs.writeText "extra_map.txt"
    (lib.concatStringsSep "\n" (lib.mapAttrsToList (k: v: "${k}\t${k} ${v}") extraMap));

in {
  xdg.dataFile = {
    "fcitx5/rime/opencc" = {
      inherit onChange;
      # source = "${inputs.rime-emoji}/opencc";
      source = pkgs.runCommand "opencc-modified" { nativeBuildInputs = [ pkgs.jq ]; } ''
        cp -rT ${inputs.rime-emoji}/opencc $out
        chmod -R +w $out
        jq '.conversion_chain[0].dict.dicts[1].file = $f' --arg f '${extraMapFile}' <$out/emoji.json >$out/emoji.json.tmp
        mv $out/emoji.json{.tmp,}
      '';
    };

    "fcitx5/rime/default.custom.yaml" = {
      inherit onChange;
      text = ''
        # encoding: utf-8

        patch:
          menu/page_size: 8

          switcher/save_options: []
          key_binder/bindings:
            - {accept: minus, send: Page_Up, when: has_menu}
            - {accept: equal, send: Page_Down, when: has_menu}
            - {accept: comma, send: Page_Up, when: paging}
            - {accept: period, send: Page_Down, when: has_menu}
            - {accept: "Control+Shift+1", select: .next, when: always}
            - {accept: "Control+Shift+2", toggle: ascii_mode, when: always}
            - {accept: "Control+Shift+3", toggle: full_shape, when: always}
            - {accept: "Control+Shift+4", toggle: simplification, when: always}
            - {accept: "Control+Shift+5", toggle: extended_charset, when: always}

          schema_list:
            - schema: double_pinyin
      '';
    };

    "fcitx5/rime/double_pinyin.custom.yaml" = {
      inherit onChange;
      text = ''
        # encoding: utf-8

        patch:
          switches:
            - name: ascii_mode
              reset: 0
              states: ["中文", "西文"]
            - name: full_shape
              reset: 0
              states: ["半角", "全角"]
            - name: simplification
              reset: 1
              states: ["漢字", "汉字"]
            - name: ascii_punct
              reset: 0
              states: ["。，", "．，"]
            - name: emoji_suggestion
              reset: 1
              states: [ "🈚️️\uFE0E", "🈶️️\uFE0F" ]

          key_binder/bindings: []

          engine/filters/@next:
            simplifier@emoji_suggestion
          emoji_suggestion:
            opencc_config: emoji.json
            option_name: emoji_suggestion
            tips: all
      '';
    };

  };
}
