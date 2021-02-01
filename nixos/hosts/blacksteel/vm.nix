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
    # Random generated UUIDs.
    # vgpus."i915-GVTg_V5_4".uuid = "7dbe463d-94fc-425c-8ccd-55d0f9d5d26b"; # 1920x1200
    vgpus."i915-GVTg_V5_8".uuid = [ "89584099-86a4-4b77-b770-16c0a93c260a" ]; # 1024x768
  };

  systemd.services."win10-hd-vm-disk" = let
    dmName = "win10-hd-vm-disk";

    devWin = "/dev/disk/by-uuid/CE8A6B398A6B1D69";
    secWin = 262047414;
    devGpt = "/dev/disk/by-partuuid/4f3131a2-ee06-425e-b3af-bbf35c00d192";
    secGptBefore = 262144; # 128 MiB
    secGptAfter = 2048; # 1 MiB

  in {
    description = "Device mapper for Windows 10 VM";
    unitConfig.RequiresMountsFor = "/home/oxa/vm/pool";
    wantedBy = [ "multi-user.target" ];
    serviceConfig.Type = "oneshot";
    serviceConfig.RemainAfterExit = true;

    path = with pkgs; [ utillinux lvm2 ];
    script = ''
      sec_win=$(blockdev --getsz ${devWin})
      sec_gpt=$(blockdev --getsz ${devGpt})
      echo "Windows partition has $sec_win sectors"
      echo "GPT partition has $sec_gpt sectors"
      if [[ "$sec_win" -ne ${toString secWin} || "$sec_gpt" -ne ${toString (secGptBefore + secGptAfter)} ]]; then
        echo "Size mismatch"
        exit 1
      fi

      dmsetup create ${dmName} <<EOF
        0 ${toString secGptBefore} linear ${devGpt} 0
        ${toString secGptBefore} ${toString secWin} linear ${devWin} 0
        ${toString (secGptBefore + secWin)} ${toString secGptAfter} linear ${devGpt} ${toString secGptBefore}
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
      path = "/home/oxa/vm/share";
      writable = "yes";
    };
  };
  networking.firewall.interfaces."virbr0" = {
    allowedTCPPorts = [ 139 445 ];
    allowedUDPPorts = [ 137 138 ];
  };
}
