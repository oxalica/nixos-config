# Ref: https://gitlab.com/NickCao/flakes/-/blob/master/nixos/local/home.nix
{ lib, pkgs, config, super, ... }:
let
  font-size = 12;

  wallpaper = pkgs.fetchurl {
    name = "wallpaper.jpg";
    url = "https://pbs.twimg.com/media/E9irhxhVUAUaBCr?format=jpg";
    hash = "sha256-Rhjj1K0FXKGzKswoLj1H0Yi/QHswzPcGW6aLMiekURA=";
  };
  wallpaper-blur = pkgs.runCommand "wallpaper-blur.jpg" { } ''
    ${pkgs.imagemagick}/bin/convert -blur 14x5 ${wallpaper} $out
  '';

in
{
  gtk = {
    enable = true;
    theme = {
      package = pkgs.materia-theme;
      name = "Materia-dark";
    };
    iconTheme = {
      package = pkgs.numix-icon-theme-circle;
      name = "Numix-Circle";
    };
    font = {
      # package = null; # pkgs.roboto;
      name = "sans-serif";
      size = font-size;
    };
    gtk2.configLocation = "${config.xdg.configHome}/gtk-2.0/gtkrc";
  };

  dconf.settings = {
    "org/gnome/desktop/interface"."gtk-theme" = "Materia-dark";
  };

  qt = {
    enable = true;
    platformTheme = "gtk";
  };

  wayland.windowManager.sway = {
    enable = true;
    xwayland = true;
    systemdIntegration = true;
    wrapperFeatures.gtk = true;

    config = rec {
      terminal = "foot";
      startup = [
        { command = "systemctl"; }
        { command = "foot"; }
        { command = "firefox"; }
        { command = "telegram-desktop"; }
        { command = "thunderbird"; }
      ];
      assigns = {
        "1" = [{ app_id = "foot"; }];
        "2" = [{ app_id = "firefox"; }];
        "3" = [{ app_id = "telegramdesktop"; }];
        "4" = [{ class = "Thunderbird"; }];
      };
      window.commands = [
        {
          criteria = { app_id = "pavucontrol"; };
          command = "floating enable, sticky enable, resize set width 550 px height 600px, move position cursor, move down 35";
        }
        {
          criteria = { urgent = "latest"; };
          command = "focus";
        }
      ];

      gaps = {
        inner = 5;
        smartGaps = true;
        smartBorders = "on";
      };
      bars = [ ];

      seat."*".hide_cursor = "when-typing enable";
      input = {
        "*".xkb_options = "ctrl:nocaps";
        "1133:49298:Logitech_G102_LIGHTSYNC_Gaming_Mouse" = {
          accel_profile = "flat";
          pointer_accel = "0";
        };
      };
      output = {
        "*".background = "${wallpaper} fill";
        DP-1.scale = "1.25";
      };

      modifier = "Mod4";
      keybindings =
        lib.mkOptionDefault {
          "${modifier}+s" = "split toggle";
          "${modifier}+b" = null;
          "${modifier}+v" = null;
          "${modifier}+w" = null;
          "${modifier}+d" = "exec ${pkgs.rofi}/bin/rofi -show run";
          "${modifier}+Shift+l" = "exec loginctl lock-session";
          "${modifier}+space" = null;
          "Print" = "exec ${pkgs.grim}/bin/grim -g \"$(${pkgs.slurp}/bin/slurp)\" $HOME/Pictures/screenshot-$(date +\"%Y-%m-%d-%H-%M-%S\").png";

          "XF86AudioPlay" = "exec ${pkgs.playerctl}/bin/playerctl play-pause";
          "XF86AudioPause" = "exec ${pkgs.playerctl}/bin/playerctl play-pause";
          "XF86AudioNext" = "exec ${pkgs.playerctl}/bin/playerctl next";
          "XF86AudioPrev" = "exec ${pkgs.playerctl}/bin/playerctl previous";
          "XF86AudioRaiseVolume" = "exec ${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ +5%";
          "XF86AudioLowerVolume" = "exec ${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ -5%";
          "XF86AudioMute" = "exec ${pkgs.pulseaudio}/bin/pactl set-sink-mute @DEFAULT_SINK@ toggle";
        };
    };
  };

  home.packages = with pkgs; [
    waypipe
    pavucontrol
  ];

  programs = {
    lf.enable = true;

    mako = {
      enable = true;
      extraConfig = ''
        on-button-right=exec ${pkgs.mako}/bin/makoctl menu -n "$id" ${pkgs.rofi}/bin/rofi -dmenu -p 'action: '
      '';
    };

    waybar = {
      enable = true;
      settings = [ (import ./waybar.nix { inherit pkgs; }) ];
      style = builtins.readFile ./waybar.css;
      systemd.enable = true;
      systemd.target = "sway-session.target";
    };

    foot = {
      enable = true;
      settings = {
        main = {
          shell = "${pkgs.tmux}/bin/tmux new-session -t main";
          font = "monospace:size=${toString font-size}";
        };
      };
    };
  };

  services = {
    swayidle = {
      enable = true;
      timeouts = [
        {
          timeout = 900; # 15min
          command = "${pkgs.swaylock-effects}/bin/swaylock";
        }
        {
          timeout = 905;
          command = ''swaymsg "output * dpms off"'';
          resumeCommand = ''swaymsg "output * dpms on"'';
        }
      ];
      events = [
        {
          event = "lock";
          command = "${pkgs.swaylock-effects}/bin/swaylock";
        }
      ];
    };
  };

  xdg.configFile."swaylock/config".text = ''
    daemonize
    image=${wallpaper-blur}
    scaling=fill
    indicator-idle-visible
    clock
    datestr=%Y-%m-%d %a
    show-failed-attempts
  '';

  systemd.user = {
    targets.sway-session.Unit.Wants = [
      "xdg-desktop-autostart.target"
      "waybar.service"
    ];

    services.mako = {
      Unit = {
        Description = "mako";
        Documentation = [ "man:mako(1)" ];
        PartOf = [ "sway-session.target" ];
      };

      Service = {
        ExecStart = "${pkgs.mako}/bin/mako";
        RestartSec = 3;
        Restart = "always";
      };

      Install.WantedBy = [ "sway-session.target" ];
    };
  };
}
