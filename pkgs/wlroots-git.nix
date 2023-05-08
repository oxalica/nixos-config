{
  source,
  wlroots_0_16,
  hwdata,
  libdisplay-info,

  enableXWayland ? true,
  xwayland ? null,
}:
(wlroots_0_16.override {
  inherit enableXWayland xwayland;
}).overrideAttrs (old: {
  inherit (source) src;
  version = "git-${source.date}";
  nativeBuildInputs = old.nativeBuildInputs or [] ++ [
    hwdata
  ];
  buildInputs = old.buildInputs or [] ++ [
    libdisplay-info
  ];
})
