{ pkgs, my, ... }:
{
  programs.gpg = {
    enable = true;
    settings = {
      default-key = my.gpg.fingerprint;
      personal-cipher-preferences = "AES256 AES192 AES TWOFISH";
      personal-digest-preferences = "SHA512 SHA256";
      personal-compress-preferences = "ZLIB BZIP2 Uncompressed";
      keyserver = "hkps://keys.openpgp.org";
    };
  };

  services.gpg-agent = {
    enable = true;
    pinentryFlavor = "qt";
    defaultCacheTtl = 2 * 3600;
    maxCacheTtl = 24 * 3600;
  };

  programs.password-store = {
    enable = true;
    package = pkgs.pass.withExtensions (ps: [ ps.pass-otp ]);
  };
}
