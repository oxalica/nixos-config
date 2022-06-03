# Ref: https://gitlab.com/NickCao/flakes/-/blob/master/nixos/local/home.nix
{ lib, pkgs, config, super, ... }:
let
  fontSize = 12;

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
  imports = [
    ./waybar.nix
  ];

  home.pointerCursor = {
    package = pkgs.gnome.adwaita-icon-theme;
    name = "Adwaita";
    size = 24;
  };

  gtk = {
    enable = true;
    theme = {
      package = pkgs.gnome-themes-extra;
      name = "Adwaita-dark";
    };
    iconTheme.name = "Adwaita";
    font = {
      name = "sans-serif";
      size = fontSize;
    };
    gtk2.configLocation = "${config.xdg.configHome}/gtk-2.0/gtkrc";
    # gtk3.extraConfig.gtk-application-prefer-dark-theme = 1;
  };

  qt.enable = true;

  wayland.windowManager.sway = {
    enable = true;
    xwayland = true;
    systemdIntegration = true;
    wrapperFeatures.gtk = true;

    config =
      let
        modifier = "Mod4";
        logoutMode = {
          name = "(l) lock, (e) logout, (s) suspend, (q) shutdown, (r) reboot";
          keys = {
            l = "mode default, exec loginctl lock-session";
            e = "mode default, exec \"swaymsg exit; loginctl terminate-session $XDG_SESSION_ID\"";
            s = "mode default, exec systemctl suspend";
            q = "mode default, exec systemctl poweroff";
            r = "mode default, exec systemctl reboot";
            Escape = "mode default";
          };
        };
      in
      {
        terminal = "alacritty -e ${pkgs.tmux}/bin/tmux new-session -t main";
        startup = [
          { command = "firefox"; }
          { command = "telegram-desktop"; }
          { command = "thunderbird"; }
        ];
        assigns = {
          # "1" = [{ app_id = "alacritty"; }];
          "2" = [{ app_id = "firefox"; }];
          "3" = [{ app_id = "telegramdesktop"; }];
          "4" = [{ app_id = "thunderbird"; }];
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

        inherit modifier;
        keybindings =
          lib.mkOptionDefault {
            "${modifier}+s" = "split toggle";
            "${modifier}+b" = null;
            "${modifier}+v" = null;
            "${modifier}+w" = null;
            "${modifier}+d" = "exec ${pkgs.rofi}/bin/rofi -show run";
            "${modifier}+Shift+l" = "exec loginctl lock-session";
            "${modifier}+Shift+e" = "mode \"${logoutMode.name}\"";
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

        modes = {
          ${logoutMode.name} = logoutMode.keys;
        };
      };
  };

  home.packages = with pkgs; [
    waypipe
    pavucontrol
    xdg-utils
  ];

  programs = {
    lf.enable = true;

    mako = {
      enable = true;
      defaultTimeout = 15;
      font = "sans-serif";
      extraConfig = ''
        on-button-right=exec ${pkgs.mako}/bin/makoctl menu -n "$id" ${pkgs.rofi}/bin/rofi -dmenu -p 'action: '
      '';
    };
  };

  services = {
    swayidle = {
      enable = true;
      timeouts = [
        {
          timeout = 900; # 15min
          command = "${pkgs.swaylock-effects}/bin/swaylock --grace=5";
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
    ];

    services.mako = {
      Unit = {
        Description = "mako";
        Documentation = [ "man:mako(1)" ];
        PartOf = [ "sway-session.target" ];
      };

      Service = {
        ExecStart = "${pkgs.mako}/bin/mako";
        Restart = "always";
      };

      Install.WantedBy = [ "sway-session.target" ];
    };
  };
}
