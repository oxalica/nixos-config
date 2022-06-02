{ pkgs, ... }:
{
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
    # "network"
    "pulseaudio"

    "cpu"
    "memory"
    "clock"
  ];

  clock = {
    interval = 1;
    format = "{:%m-%d %a %H:%M:%S}";
    tooltip = true;
    tooltip-format = "<big>{:%Y-%m-%d %a}</big>\n<tt><small>{calendar}</small></tt>";
  };

  cpu = {
    interval = 5;
    format = "{usage}%";
  };

  memory = {
    interval = 5;
    format = "{used:0.1f}/{total:0.1f}G {swapUsed:0.1f}G";
  };

  "sway/workspaces" = {
    all-outputs = true;
    format = "{name}{icon}";
    format-icons = { default = ""; urgent = " [!]"; };
  };

  network = {
    format-disconnected = "🕷";
    format-linked = "🖧";
    format-wifi = "📶";
    on-click = "${pkgs.networkmanagerapplet}/bin/nm-connection-editor";
  };

  pulseaudio = {
    format = "{volume}%🔈{format_source}";
    format-muted = "🔇{format_source}";
    format-source = " {volume}% 🎤";
    format-source-muted = "";
    on-click = "${pkgs.pavucontrol}/bin/pavucontrol";
  };

  tray = {
    spacing = 10;
  };
}
