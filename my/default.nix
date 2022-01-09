{
  gpg = {
    fingerprint = "F90FFD6D585C2BA1F13DE8A97571654CF88E31C2";
    publicKeyFile = ./gpg-pubkey.asc;
  };

  ssh = rec {
    identities = {
      oxa-invar = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJYl9bIMoMrs8gWUmIAF42mGnKVxqY6c+g2gmE6u2E/B oxa@invar";
      oxa-blacksteel = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICU0P/fbBnnPCVni+efxfl//NQ1jeOe4lUDH6okvLzr1 oxa@blacksteel";
    } // builtins.mapAttrs (name: value: value.publicKey) knownHosts;

    knownHosts = {
      invar.publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPp0GGkE81OeO1JUQ+T/DfsjzQSNRz1lzpNTU+UgpAv1";
      blacksteel.publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICVBNvOEn0ncdylnKQIFKd75muElg5TBaMFWrbamAlx+";

      silver = {
        hostNames = [ "|1|djhJoriV/JqzO+LqNj6+kJ0SLFk=|SHA3YNffReFWcG8oW5AvH4EePek=" ];
        publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAVLDuh0BHrcbD5Nsla2C/ylOHkbN4UkcRYZP5dj9kCs";
      };
      copper = {
        hostNames = [ "|1|dBmAkr6d+gTzhvfiA8p7l+H34co=|3U8aEJXTtWbmM/j/c+qAGKb44d8=" ];
        publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO1TnA8NpurpJFgf4xZZvJrgFpkaE9y6qRgFiFe1mX21";
      };
      lithium = {
        hostNames = [ "|1|03iz3vLed3+JuFU4jY9i+nna9Uc=|F1vUXreBxQBexS9B8ocVVVvv8Hc=" ];
        publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGafc2sPL47lOJECY1K2X7p2nzfxrLoCMvJ15W/wiJ80";
      };

      hex0 = {
        hostNames = [ "|1|8qZR6bR7/4FL6i7++APyedULh2s=|9OcPkxvketTeD5jQTqTxqcCbufg=" ];
        publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBGiu2G4V9jdAF2JRNN1+3tqYfCldPrwepwYFs1usW9C";
      };
    };
  };
}
