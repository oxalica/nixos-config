{ lib, ... }:
{
  nix.binaryCaches = lib.mkBefore [
    "https://mirror.sjtu.edu.cn/nix-channels/store"
    # "https://mirrors.bfsu.edu.cn/nix-channels/store"
    # Do no try to enable TUNA! Scary thing will happen!
    # "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store" # May suffer from download stalled issue.
    # "https://mirrors.ustc.edu.cn/nix-channels/store"
  ];
}
