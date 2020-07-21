{ ... }:
{
  time.timeZone = "Asia/Shanghai";

  nix.binaryCaches = [
    "https://mirrors.bfsu.edu.cn/nix-channels/store"
  ];

  networking.timeServers = [
    "cn.ntp.org.cn"
    "edu.ntp.org.cn"
    "time.pool.aliyun.com"
    "time1.cloud.tencent.com"
  ];
}
