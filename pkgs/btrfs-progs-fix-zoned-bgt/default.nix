{ btrfs-progs }:
btrfs-progs.overrideAttrs (old: {
  pname = "btrfs-progs-fix-zoned-bgt";

  patches = old.patches or [ ] ++ [
    ./pr-767-zoned-bgt.patch
  ];
})
