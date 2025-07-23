# Ref: https://x86.lol/generic/2024/08/28/systemd-sysupdate.html
{
  lib,
  config,
  pkgs,
  modulesPath,
  ...
}:
let
  inherit (lib)
    mkOption
    types
    ;

  inherit (pkgs.hostPlatform) efiArch;

  cfg = config.vultrImage;
in
{
  imports = [
    (modulesPath + "/image/repart.nix")
  ];

  options.vultrImage = {
    name = mkOption {
      type = types.str;
      description = "The name of the generated derivation";
      default = "nixos-vultr-image-${config.system.nixos.label}-${pkgs.stdenv.hostPlatform.system}";
    };

    efiPartSize = mkOption {
      type = types.str;
      default = "128M";
      example = "256M";
      description = "The start offset of EFI partition.";
    };
  };

  config.image.repart = {
    name = cfg.name;
    compression.enable = true;
    mkfsOptions.btrfs = [ "--shrink" ];
    partitions = {
      "10-esp" = {
        contents = {
          "/EFI/BOOT/BOOT${lib.toUpper efiArch}.EFI".source =
            "${pkgs.systemd}/lib/systemd/boot/efi/systemd-boot${efiArch}.efi";
          "/EFI/Linux/${config.system.boot.loader.ukiFile}".source =
            "${config.system.build.uki}/${config.system.boot.loader.ukiFile}";
        };
        repartConfig = {
          Label = "ESP";
          Type = "esp";
          Format = "vfat";
          SizeMinBytes = cfg.efiPartSize;
          SizeMaxBytes = cfg.efiPartSize;
        };
      };
      "20-root" = {
        storePaths = [ config.system.build.toplevel ];
        repartConfig = {
          Label = "nixos";
          Type = "root";
          Format = "btrfs";
          Minimize = "guess";
          # WAIT: `Compression=` for btrfs needs systemd 257
          # https://github.com/systemd/systemd/pull/34239
        };
      };
    };
  };
}
