{ hydroxide }:
hydroxide.overrideAttrs (old: {
  patches = old.patches or [] ++ [
    # https://github.com/emersion/hydroxide/issues/235#issuecomment-1544392881
    ./0001-Always-set-appversion-header-to-Other.patch
  ];
})
