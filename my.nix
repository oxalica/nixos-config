{
  ssh.identities = {
    oxa-invar = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJYl9bIMoMrs8gWUmIAF42mGnKVxqY6c+g2gmE6u2E/B oxa@invar";
    oxa-blacksteel = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICU0P/fbBnnPCVni+efxfl//NQ1jeOe4lUDH6okvLzr1 oxa@blacksteel";
  };

  ssh.knownHosts = {
    invar.publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPp0GGkE81OeO1JUQ+T/DfsjzQSNRz1lzpNTU+UgpAv1";
    blacksteel.publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICVBNvOEn0ncdylnKQIFKd75muElg5TBaMFWrbamAlx+";

    silver = {
      hostNames = [ "|1|djhJoriV/JqzO+LqNj6+kJ0SLFk=|SHA3YNffReFWcG8oW5AvH4EePek=" ];
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAVLDuh0BHrcbD5Nsla2C/ylOHkbN4UkcRYZP5dj9kCs";
    };
    copper = {
      hostNames = [ "|1|VLnsdh/DVlvGZH6aVA0J8K685Dk=|I7BmmPjbRqtq2yyE5RBIAXFdOkc=" ];
      publicKey = "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBII0BywXrUjKi42/TU1MwWjiJbYK/TwAOagV/y/LYzd9aXYPHMsZPJypsPQH5gjGEDGLiaSUYPjPOzoChsFyO3U=";
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
}