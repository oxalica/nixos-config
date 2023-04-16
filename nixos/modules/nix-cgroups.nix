{
  nix.settings = {
    experimental-features = [
      "auto-allocate-uids"
      "cgroups"
    ];
    auto-allocate-uids = true;
    use-cgroups = true;
  };
}
