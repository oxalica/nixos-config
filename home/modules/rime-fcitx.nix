{ pkgs, ... }:

let
  onChange = ''
    if [[ ! -v fcitxRestarted ]]; then
      fcitxRestarted=1
      $DRY_RUN_CMD rm -rf "$HOME/.config/fcitx/rime/build"
      $DRY_RUN_CMD fcitx -dr 2>/dev/null
    fi
  '';

  rime-emoji-opencc = pkgs.stdenv.mkDerivation {
    name = "rime-emoji-opencc-stripped";

    src = pkgs.fetchFromGitHub {
      owner = "rime";
      repo = "rime-emoji";
      rev = "6ee7ce65b21cd0fd8df0306a7c77a067f18fb55f";
      sha256 = "1kmcfs5r4904b4fsq5ngb9ippagjffbz3rfsrs3krlmnzf1aq55c";
    };

    installPhase = ''
      cp -r opencc $out
    '';
  };

in {
  xdg.configFile = {
    "fcitx/rime/opencc" = {
      inherit onChange;
      source = rime-emoji-opencc;
    };

    "fcitx/rime/default.custom.yaml" = {
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

    "fcitx/rime/double_pinyin.custom.yaml" = {
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
