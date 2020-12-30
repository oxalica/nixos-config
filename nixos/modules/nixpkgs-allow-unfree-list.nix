{ lib, config, ... }:
with lib;
let cfg = config.nixpkgsAllowUnfreeList; in
{
  options.nixpkgsAllowUnfreeList = mkOption {
    type = with types; nullOr (listOf str);
    description = ''
      <option>pname</option>s allowed to be unfree.
    '';
    example = [ "unrar" ];
  };

  config = mkIf (cfg != null) {
    nixpkgs.config.allowUnfreePredicate = drv: elem (getName drv) cfg;
  };
}
