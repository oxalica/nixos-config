# Modified from nixos/maintainers/scripts/ec2/amazon-image.nix
{ lib, config, pkgs, inputs, ... }:
with lib;
let
  cfg = config.vultrImage;
in
{
  options.vultrImage = {
    name = mkOption {
      type = types.str;
      description = "The name of the generated derivation";
      default = "nixos-vultr-image-${config.system.nixos.label}-${pkgs.stdenv.hostPlatform.system}";
    };

    contents = mkOption {
      example = literalExpression ''
        [ { source = pkgs.memtest86 + "/memtest.bin";
            target = "boot/memtest.bin";
          }
        ]
      '';
      default = [];
      description = ''
        This option lists files to be copied to fixed locations in the
        generated image. Glob patterns work.
      '';
    };

    diskSize = mkOption {
      type = with types; either (enum [ "auto" ]) int;
      default = 2048;
      example = 8192;
      description = "The size in MB of the image";
    };
  };

  config.system.build.vultrImage = import (inputs.nixpkgs + "/nixos/lib/make-disk-image.nix") {
    inherit lib config pkgs;
    inherit (cfg) name contents diskSize;

    format = "raw";
    fsType = "ext4";
    partitionTableType = "legacy";
    label = "nixos"; # Root filesystem label.
    # copyChannel = false; # Not available in nixos-21.05.
  };
}
