{
  config,
  pkgs,
  my,
  ...
}:
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
    scdaemonSettings = {
      deny-admin = true;
    };
  };

  services.gpg-agent = {
    enable = true;
    enableScDaemon = true;
    enableSshSupport = true;

    pinentry.package = pkgs.pinentry-qt;
    defaultCacheTtl = 600; # Default
    maxCacheTtl = 1800; # Default
  };

  programs.password-store = {
    enable = true;
    package = pkgs.pass.withExtensions (ps: [
      ps.pass-audit
      ps.pass-import
      ps.pass-otp
    ]);
    settings.PASSWORD_STORE_DIR = "${config.home.homeDirectory}/storage/5x-state/51-secret/51.10-password-store";
  };

  home.packages = [ pkgs.qtpass ];
}
