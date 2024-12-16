# See: <https://bugs.kde.org/show_bug.cgi?id=497571>
# TODO: Upstream this patch. Need some non-trivial rebase.
{
  kdePackages,
}:
kdePackages.kwin.overrideAttrs (oldAttrs: {
  patches = oldAttrs.patches or [ ] ++ [
    ./0001-Report-preferred-buffer-size-for-window-screencastin.patch
  ];
})
