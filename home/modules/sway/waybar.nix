# FIXME: Broken onChange script.
{ pkgs, ... }:
{
  programs.waybar = {
    enable = true;
    style = ./waybar.css;
    systemd.enable = true;
    systemd.target = "sway-session.target";

    settings.mainBar = {
      layer = "top";
      position = "top";
      height = 25;

      modules-left = [
        "sway/workspaces"
        "sway/mode"
      ];

      modules-center = [
        "sway/window"
      ];

      modules-right = [
        "tray"
        "pulseaudio"
        "network"
        "cpu"
        "memory"
        "clock"
      ];

      "sway/workspaces" = {
        all-outputs = true;
        # format = "{name}";
      };

      clock = {
        interval = 1;
        format = "{:%Y-%m-%d %a %H:%M:%S}";
        tooltip = true;
        tooltip-format = "<big>{:%Y-%m-%d %a}</big>\n<tt><small>{calendar}</small></tt>";
      };

      cpu = {
        interval = 1;
        format = "{load:2.1}";
      };

      memory = {
        interval = 1;
        format = "{used:0.1f}/{total:0.1f}+{swapUsed:0.1f}G";
      };

      network = {
        interval = 1;
        format-ethernet = "WIRED";
        format-wifi = "WIFI";
        format-linked = "LINKED";
        format-disconnected = "NONET";
        on-click = "${pkgs.networkmanagerapplet}/bin/nm-connection-editor";
      };

      pulseaudio = {
        format = "{volume}%{format_source}";
        format-muted = "MUTE{format_source}";
        format-source = " {volume}%";
        format-source-muted = "";
        on-click = "${pkgs.pavucontrol}/bin/pavucontrol";
      };

      tray = {
        spacing = 10;
      };
    };
  };
}
