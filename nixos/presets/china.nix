{ lib, config, ... }:
{
  options.oxa-config.preset.china = mkOption "localization for machines in mainland China";

  config = mkIf config.oxa-config.preset.china {
    nix.binaryCaches = [
      "https://mirrors.bfsu.edu.cn/nix-channels/store"
      # "cache.nixos.org" will be automatically added.
    ];

    networking.timeServers = [
      "cn.ntp.org.cn"
      "edu.ntp.org.cn"
      "time.pool.aliyun.com"
      "time1.cloud.tencent.com"
    ];
  };
}
