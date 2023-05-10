{ lib, pkgs, ... }:
let
  inherit (builtins) toJSON;
  inherit (lib) mapAttrsToList concatStringsSep concatMapStringsSep isAttrs isList;

  toTOML = obj:
    concatStringsSep "\n"
      (mapAttrsToList
        (name: value: "${toJSON name}=${toTOMLInline value}")
        obj);
  toTOMLInline = obj:
    if isAttrs obj then
      "{${concatStringsSep ","
        (mapAttrsToList
          (name: value: "${toJSON name}=${toTOMLInline value}")
          obj)
      }}"
    else if isList obj then
      "[${concatMapStringsSep "," toTOMLInline obj}]"
    else
      toJSON obj;

in {
  home.packages = with pkgs; [ helix ];

  xdg.configFile = {
    "helix/config.toml".text = toTOML {
      theme = "nightfox";

      editor = {
        scrolloff = 5;
        scroll-lines = 5;
        shell = [ "${lib.getBin pkgs.zsh}/bin/zsh" "-c" ];
        idle-timeout = 0;

        lsp.display-messages = true;
        auto-pairs = true;

        # Wait for: https://github.com/helix-editor/helix/commit/20162a426b991f1a07f347f8180480871d15a27a
        # auto-format = false;

        cursor-shape = {
          normal = "block";
          insert = "bar";
          select = "block";
        };
      };

      keys = {
        normal = {
          "g"."h" = [ "select_mode" "goto_line_start" "normal_mode" ];
          "g"."l" = [ "select_mode" "goto_line_end" "normal_mode" ];
          "x" = "extend_to_line_bounds";
          "X" = "extend_line";
        };
        insert = {
          "C-space" = "completion";
        };
      };
    };

    "helix/themes/nightfox.toml".text = toTOML {
      palette = rec {
        black = "#393b44";
        black_bright = "#575860";
        black_dim = "#30323a";
        blue = "#719cd6";
        blue_bright = "#86abdc";
        blue_dim = "#6085b6";
        cyan = "#63cdcf";
        cyan_bright = "#7ad4d6";
        cyan_dim = "#54aeb0";
        green = "#81b29a";
        green_bright = "#8ebaa4";
        green_dim = "#6e9783";
        magenta = "#9d79d6";
        magenta_bright = "#baa1e2";
        magenta_dim = "#8567b6";
        orange = "#f4a261";
        orange_bright = "#f6b079";
        orange_dim = "#cf8a52";
        pink = "#d67ad2";
        pink_bright = "#dc8ed9";
        pink_dim = "#b668b2";
        red = "#c94f6d";
        red_bright = "#d16983";
        red_dim = "#ab435d";
        white = "#dfdfe0";
        white_bright = "#e4e4e5";
        white_dim = "#bebebe";
        yellow = "#dbc074";
        yellow_bright = "#e0c989";
        yellow_dim = "#baa363";

        comment = "#768390";

        bg            = "#192330";
        bg_float      = "#131a24";
        bg_cursorline = "#29394e";
        bg_border     = "#415166";
        bg_sel        = "#223249";
        bg_search     = "#3a567d";
        bg_incsearch  = green;
        fg            = "#cdcecf";
        fg_status     = "#aeafb0";
        fg_linenr     = "#71839b";


        bracket       = fg_status;        # Brackets and Punctuation
        builtin_var   = red;              # Builtin variable
        builtin_type  = cyan_bright;      # Builtin type
        builtin_const = orange_bright;    # Builtin const
        conditional   = magenta_bright;   # Conditional and loop
        const         = orange_bright;    # Constants, imports and booleans
        deprecated    = fg_linenr;        # Deprecated
        field         = fg_status;        # Field
        func          = blue_bright;      # Functions and Titles
        ident         = cyan;             # Identifiers
        keyword       = magenta;          # Keywords
        number        = orange;           # Numbers
        operator      = fg_status;        # Operators
        preproc       = pink_bright;      # PreProc
        regex         = yellow_bright;    # Regex
        statement     = magenta;          # Statements
        string        = green;            # Strings
        type          = yellow;           # Types
        variable      = white;            # Variables

        error         = red;
        warning       = yellow;
        info          = blue;
        hint          = green;

        added         = green;
        removed       = red;
        changed       = yellow;
      };

      "ui.text".fg = "fg";
      "ui.text.focus".fg = "fg";
      "ui.background".bg = "bg";
      "ui.virtual.whitespace".fg = "bg_cursorline";
      # "ui.virtual.ruler" = { bg = "gray" }

      "ui.cursor".bg = "bg_incsearch";
      "ui.cursor.primary".modifiers = ["reversed"];
      "ui.cursor.select".bg = "bg_incsearch";
      "ui.cursor.match" = { fg = "yellow"; modifiers = ["bold"]; };

      "ui.selection".bg = "bg_sel";
      "ui.selection.primary".bg = "bg_search";

      "ui.linenr".fg = "fg_linenr";
      "ui.linenr.selected".fg = "yellow";

      "ui.statusline" = { fg = "fg_status"; bg = "bg_float"; };
      "ui.statusline.inactive" = { fg = "fg_linenr"; bg = "bg_float"; };

      "ui.help".bg = "bg_sel";
      "ui.popup".bg = "bg_sel";
      "ui.menu".bg = "bg_sel";
      "ui.menu.selected".bg = "bg_search";
      "ui.window".fg = "fg_linenr";

      "warning".fg = "warning";
      "error".fg = "error";
      "info".fg = "info";
      "hint".fg = "hint";
      "diagnostic".modifiers = ["underlined"];

      "diff.plus".fg = "added";
      "diff.minus".fg = "deleted";
      "diff.delta".fg = "changed";

      # "markup.heading" =

      "attribute".fg = "const";
      "comment".fg = "comment";
      "constant".fg = "const";
      "constant.builtin".fg = "builtin_const";
      "constant.character".fg = "string";
      "constant.character.escape" = { fg = "regex"; modifiers = ["bold"]; };
      "constant.numeric".fg = "number";
      "constructor".fg = "keyword";
      "function".fg = "func";
      "function.builtin".fg = "builtin_var";
      "function.macro".fg = "preproc";
      "keyword".fg = "keyword";
      "keyword.control".fg = "conditional";
      "keyword.control.import".fg = "preproc";
      "keyword.directive".fg = "constant";
      "keyword.function".fg = "builtin_var";
      "keyword.operator".fg = "operator";
      "label".fg = "conditional";
      "namespace".fg = "builtin_type";
      "operator".fg = "operator";
      "property".fg = "field";
      "special".fg = "func";
      "string".fg = "string";
      "string.regexp".fg = "regex";
      "string.special".fg = "func";
      "type".fg = "type";
      "variable".fg = "variable";
      "variable.builtin".fg = "builtin_var";
      "variable.other.member".fg = "field";
      "variable.parameter".fg = "builtin_var";

      # "markup.heading".fg = "";
    };
  };
}
