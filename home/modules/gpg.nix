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
  };

  programs.password-store = {
    enable = true;
    package = pkgs.pass.withExtensions (ps: [ ps.pass-otp ]);
  };
}
