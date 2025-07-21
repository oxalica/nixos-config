{
  lib,
  makeDesktopItem,
  wl-mirror,
}:
makeDesktopItem {
  name = "show-headless1";
  desktopName = "Show Headless Output 1";
  comment = "Show content of headless output HEADLESS-1";
  exec = "${lib.getBin wl-mirror}/bin/wl-mirror HEADLESS-1";
  categories = [ "Utility" ];
}
