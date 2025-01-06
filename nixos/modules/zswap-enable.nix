{ ... }: {
  systemd.tmpfiles.settings."zswap" = {
    "/sys/module/zswap/parameters/enabled"."w-".argument = "0";
    "/sys/module/zswap/parameters/zpool"."w-".argument = "zsmalloc";
  };
}
