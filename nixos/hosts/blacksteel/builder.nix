{ lib, pkgs, inputs, ... }:

{
  nix.distributedBuilds = true;
  nix.buildMachines = [
    /*
    {
      hostName = "invar";
      # FIXME: build user.
      sshUser = "oxa";
      sshKey = "/root/.ssh/id_build";
      system = "x86_64-linux";
      maxJobs = 4;
      speedFactor = 1;
      supportedFeatures = [ "kvm" "big-parallel" ];
    }
    */
    {
      hostName = "silver";
      # FIXME: build user.
      sshUser = "oxa";
      sshKey = "/root/.ssh/id_build";
      system = "x86_64-linux";
      maxJobs = 4;
      speedFactor = 1;
      supportedFeatures = [ "kvm" "big-parallel" ];
    }
  ];
}
