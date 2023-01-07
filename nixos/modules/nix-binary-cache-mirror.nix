{ lib, ... }:
let
  urls = [
    # "https://mirror.sjtu.edu.cn/nix-channels/store" # Frequent download stall.
    "https://mirrors.bfsu.edu.cn/nix-channels/store"

    # Do no try to enable TUNA! Scary thing will happen!
    # "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store" # May suffer from download stalled issue.
    # "https://mirrors.ustc.edu.cn/nix-channels/store"
  ];
in
{
  nix.settings.substituters = lib.mkBefore urls;
}
