{ pkgs, ... }:

{
  home.packages = with pkgs; [
    hydroxide
    birdtray
    thunderbird # birdtray runs `~/.nix-profile/bin/thunderbird`
  ];

  desktop-autostart."birdtray" = {
    desktopName = "Birdtray";
    exec = "birdtray";
  };

  systemd.user.services."hydroxide" = {
    Unit.Description = "Bridge to ProtonMail";
    Install.WantedBy = [ "default.target" ];
    Service.ExecStart = "${pkgs.hydroxide}/bin/hydroxide serve";
  };
}
