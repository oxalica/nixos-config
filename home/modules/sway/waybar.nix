# Reference: https://github.com/Egosummiki/dotfiles/tree/f6577e7c7b9474e05d62c0e6e0d38fee860ea4ea/waybar
{ pkgs, ... }:
{
  systemd.user.services.waybar.Service.Slice = "session.slice";
  programs.waybar = {
    enable = true;
    style = pkgs.substituteAll {
      src = ./waybar.css;
      fontSize = 14;
    };
    systemd.enable = true;
    systemd.target = "sway-session.target";

    settings.mainBar = {
      layer = "top";
      position = "top";
      height = 24;

      modules-left = [
        "sway/workspaces"
        "sway/mode"
      ];

      modules-center = [
        "sway/window"
      ];

      modules-right = [
        "pulseaudio"
        "network"
        "cpu"
        "memory"
        "battery"
        "tray"
        "clock"
      ];

      "sway/workspaces" = {
        all-outputs = true;
        format = "{icon}";
        format-icons = {
          "1" = "";
          "2" = "";
          "3" = "";
          "4" = "";
          "5" = "5";
          "6" = "6";
          "7" = "7";
          "8" = "8";
          "9" = "9";
        };
      };

      clock = {
        interval = 1;
        format = "{:%Y-%m-%d %H:%M:%S}";
        tooltip = true;
        tooltip-format = "<big>{:%Y-%m-%d %a}</big>\n<tt>{calendar}</tt>";
      };

      cpu = {
        interval = 1;
        format = " {usage}%";
      };

      memory = {
        interval = 1;
        format = " {used:0.1f}/{total:0.1f}+{swapUsed:0.1f}G";
      };

      battery = {
        bat = "BAT0";
        format = "{icon} {capacity}%";
        states = {
          warning = 30;
          critical = 15;
        };
        format-icons = ["" "" "" "" ""];
      };

      network = {
        format-ethernet = " ";
        format-wifi = " {essid} {signalStrength}%";
        format-linked = " {ifname}";
        format-disconnected = " ";
      };

      pulseaudio = {
        format = "{icon} {volume}% {format_source}";
        format-bluetooth = "{icon}  {volume}%";
        format-muted = " {format_source}";
        format-source = "  {volume}%";
        format-source-muted = "";
        format-icons = {
            headphones = "";
            handsfree = "";
            headset = "";
            phone = "";
            portable = "";
            car = "";
            default = ["" ""];
        };
        scroll-step = 2.0;
        on-click = "pkill -f -x ${pkgs.pavucontrol}/bin/pavucontrol || ${pkgs.pavucontrol}/bin/pavucontrol";
      };

      tray = {
        spacing = 6;
      };
    };
  };
}
