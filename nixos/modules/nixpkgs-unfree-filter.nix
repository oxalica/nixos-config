{ lib, config, ... }:
with lib;
let cfg = nixpkgs-unfree-filter; in
{
  options.nixpkgs-unfree-filter = {
    enable = mkEnableOption "management of nixpkgs unfree packages";

    allowedPnames = mkOption {
      type = with types; listOf str;
      description = ''
        <option>pname</option>s allowed to be unfree.
      '';
      example = [ "unrar" ];
    };
  };

  config = mkIf cfg.enable {
    nixpkgs.allowUnfreePredicate = drv: elem (getName drv) cfg.allowedPnames;
  };
}
