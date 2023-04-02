{
  gpg = {
    fingerprint = "F90FFD6D585C2BA1F13DE8A97571654CF88E31C2";
    publicKeyFile = ./gpg-pubkey.asc;
  };

  ssh = rec {
    identities = {
      oxa = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHn7rLiEt5UHKNsX/uNam7679guLh4chbYdE2eoC00+p openpgp:0x4E59DAB9";

      oxa-invar = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJYl9bIMoMrs8gWUmIAF42mGnKVxqY6c+g2gmE6u2E/B oxa@invar";
      oxa-blacksteel = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICU0P/fbBnnPCVni+efxfl//NQ1jeOe4lUDH6okvLzr1 oxa@blacksteel";
      shu-iwkr = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOtqhzrEH5VnSSxcLn7MJKbCw7QFhQmX8hkSmsEMq8/I shu@iwkr";
    } // builtins.mapAttrs (name: value: value.publicKey) knownHosts;

    knownHosts = {
      invar.publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPp0GGkE81OeO1JUQ+T/DfsjzQSNRz1lzpNTU+UgpAv1";
      blacksteel.publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICVBNvOEn0ncdylnKQIFKd75muElg5TBaMFWrbamAlx+";
      iwkr.publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEmt0cK3uNWAtpK2k3BA+liaIKWFPa8mDtRh15GAjF3J";

      copper = {
        extraHostNames = [ "|1|dBmAkr6d+gTzhvfiA8p7l+H34co=|3U8aEJXTtWbmM/j/c+qAGKb44d8=" ];
        publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO1TnA8NpurpJFgf4xZZvJrgFpkaE9y6qRgFiFe1mX21";
      };
      lithium = {
        extraHostNames = [ "|1|03iz3vLed3+JuFU4jY9i+nna9Uc=|F1vUXreBxQBexS9B8ocVVVvv8Hc=" ];
        publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGafc2sPL47lOJECY1K2X7p2nzfxrLoCMvJ15W/wiJ80";
      };

      aluminum = {
        extraHostNames = [ "aluminum.lan.hexade.ca" ];
        publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOqzykYcCVpDJqkayG8tzoh3AurOsilAsBTX7heF0h3u";
      };
    };
  };
}
