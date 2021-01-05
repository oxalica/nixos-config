{ lib, ... }:
{
  nix.binaryCaches = lib.mkBefore [
    # "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store" # May suffer from download stalled issue.
    "https://mirrors.bfsu.edu.cn/nix-channels/store"
    # "https://mirrors.ustc.edu.cn/nix-channels/store"
  ];
}
