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
  # Workaround: This file is imported by ISO configuration which uses nixpkgs-21.11.
  nix = if builtins.compareVersions lib.version "21.11" < 0
    then { binaryCaches = lib.mkBefore urls; }
    else { settings.substituters = lib.mkBefore urls; };
}
