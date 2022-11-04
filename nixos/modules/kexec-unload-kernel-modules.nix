# Ref: https://wiki.archlinux.org/title/Kexec#No_kernel_mode-setting_(Nvidia)
{ lib, config, pkgs, ... }:
let
  inherit (lib) types mkOption mkIf;
  cfg = config.boot.kexecUnloadKernelModules;
in {
  options = {
    boot.kexecUnloadKernelModules = mkOption {
      default = [ ];
      type = with types; listOf str;
      description = lib.mdDoc "Kernel modules to unload right before kexec.";
    };
  };

  config = mkIf (cfg != [ ]) {
    systemd.services.kexec-unload-kernel-modules = {
      description = "Unload kernel modules for kexec";
      wantedBy = [ "kexec.target" ];
      after = [ "umount.target" ];
      before = [ "kexec.target" ];
      unitConfig = {
        DefaultDependencies = false;
      };
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.kmod}/bin/modprobe -r -a ${lib.escapeShellArgs cfg}";
      };
    };
  };
}
