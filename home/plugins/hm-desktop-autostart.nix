{ lib, config, pkgs, ... }:

with lib;

let
  cfg = config.desktop-autostart;

in {
  options = {
    desktop-autostart = mkOption {
      default = {};
      type = types.attrsOf (types.attrsOf types.unspecified);
    };
  };

  config = {
    assertions = mapAttrsToList (name: _: {
      assertion = builtins.match ".*/.*" name == null;
      message = "Invalid desktop file name in "
        + "desktop-autostart.\"${escape ["\\"] name }\"";
    }) cfg;

    xdg.configFile = mapAttrs' (name: args: {
      name = "autostart/${name}.desktop";
      value.source = "${
        pkgs.makeDesktopItem ({
          inherit name;
          desktopName = name;
        } // args)
      }/share/applications/${args.name or name}.desktop";
    }) cfg;
  };
}
