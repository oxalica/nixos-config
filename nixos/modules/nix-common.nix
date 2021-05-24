{ pkgs, inputs, ... }:
{
  nix = {
    # Ensure that flake support is enabled.
    package = pkgs.nixFlakes;

    useSandbox = true;

    # FIXME: Workaround for https://github.com/NixOS/nixpkgs/issues/124215
    sandboxPaths = [ "/bin/sh=${pkgs.bash}/bin/sh" ];

    trustedUsers = [ "root" "oxa" ];

    gc = {
      automatic = true;
      dates = "Wed";
      options = "--delete-older-than 8d";
    };

    autoOptimiseStore = true;
    # optimise = {
    #   automatic = true;
    #   dates = [ "Thu" ];
    # };

    extraOptions = ''
      experimental-features = nix-command flakes
      flake-registry = /etc/nix/registry.json

      download-attempts = 5
      connect-timeout = 15
      stalled-download-timeout = 10

      keep-outputs = true # Keep build-dependencies.
    '';

    registry = {
      nixpkgs = {
        from = { id = "nixpkgs"; type = "indirect"; };
        flake = inputs.nixpkgs;
      };
    };

    nixPath = [
      "nixpkgs=${inputs.nixpkgs}"
      "home-manager=${inputs.home-manager}"
    ];
  };
}
