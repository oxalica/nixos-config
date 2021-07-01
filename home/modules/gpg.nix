{ pkgs, ... }:
{
  programs.gpg = {
    enable = true;
    settings = {
      default-key = "5CB0E9E5D5D571F57F540FEACED392DE0C483D00";
      personal-compress-preferences = "Uncompressed ZLIB";
    };
  };

  services.gpg-agent = {
    enable = true;
    pinentryFlavor = "qt";
    # enableSshSupport = true;
    defaultCacheTtl = 12 * 3600;
    maxCacheTtl = 24 * 3600;
  };

  programs.password-store = {
    enable = true;
    package = pkgs.pass.withExtensions (ps: [ ps.pass-otp ]);
  };
}
