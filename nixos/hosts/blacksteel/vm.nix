{ pkgs, ... }:

{
  virtualisation.docker.enable = true;
  users.groups."docker".members = [ "oxa" ];

  virtualisation.libvirtd = {
    enable = true;
    qemuPackage = pkgs.qemu_kvm;
  };
  users.groups."libvirtd".members = [ "oxa" ];
  virtualisation.kvmgt = {
    enable = true;
    # vgpus."i915-GVTg_V5_4".uuid = "7dbe463d-94fc-425c-8ccd-55d0f9d5d26b"; # 1920x1200
    vgpus."i915-GVTg_V5_8".uuid = [ "89584099-86a4-4b77-b770-16c0a93c260a" ]; # 1024x768
  };

  systemd.services."win10-hd-vm-disk" = let
    dmName = "win10-hd-vm-disk";
    # GPT header and EFI partition
    dev1 = "/dev/disk/by-partuuid/89bbf7e6-dd4f-41b8-86e5-a6d846c0385d";
    # Windows
    dev2 = "/dev/disk/by-uuid/CE8A6B398A6B1D69";
    # GPT backup header
    dev3 = "/dev/disk/by-partuuid/a9501dad-1b22-1740-a88e-88e5d8981426";

  in {
    description = "Device mapper for Windows 10 VM";
    after = [ "-.mount" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig.Type = "oneshot";
    serviceConfig.RemainAfterExit = true;

    path = with pkgs; [ utillinux lvm2 ];
    script = ''
      SEC1=$(blockdev --getsz ${dev1})
      SEC2=$(blockdev --getsz ${dev2})
      SEC3=$(blockdev --getsz ${dev3})
      dmsetup create ${dmName} <<EOF
        0 $SEC1 linear ${dev1} 0
        $SEC1 $SEC2 linear ${dev2} 0
        $((SEC1 + SEC2)) $SEC3 linear ${dev3} 0
      EOF
    '';
    preStop = ''
      dmsetup remove ${dmName}
    '';
  };

  # Local samba for VM
  services.samba = {
    enable = true;
    extraConfig = ''
      bind interfaces only = yes
      interfaces = lo virbr0
      guest account = nobody
    '';
    shares."vm_share" = {
      path = "/home/oxa/vm_share";
      writable = "yes";
    };
  };
  networking.firewall.interfaces."virbr0" = {
    allowedTCPPorts = [ 139 445 ];
    allowedUDPPorts = [ 137 138 ];
  };
}
