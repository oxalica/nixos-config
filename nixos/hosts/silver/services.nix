{ ... }:
{
  services.openssh = {
    enable = true;
    # passwordAuthentication = false;
    # challengeResponseAuthentication = false;
    extraConfig = ''
      ClientAliveInterval 70
      ClientAliveCountMax 3
    '';
  };
}
