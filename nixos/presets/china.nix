{ ... }:
{
  time.timeZone = "Asia/Shanghai";

  nix.binaryCaches = [
    "https://mirrors.bfsu.edu.cn/nix-channels/store"
  ];
}
