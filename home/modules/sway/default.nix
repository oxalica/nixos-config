# Ref: https://gitlab.com/NickCao/flakes/-/blob/master/nixos/local/home.nix
{ lib, pkgs, config, my, ... }:
let
  rofi = "${config.programs.rofi.finalPackage}/bin/rofi";

  terminal = "${pkgs.alacritty}/bin/alacritty";

  sway = config.wayland.windowManager.sway.package;

  # FIXME: https://github.com/jirutka/swaylock-effects/issues/3
  # swaylock = my.pkgs.swaylock-effects;
  swaylock = pkgs.swaylock;

in
{
  imports = [
    ./waybar.nix
  ];

  home.packages = (with pkgs; [
    waypipe
    pavucontrol
    grim
    slurp
    swaylock
    sway-contrib.grimshot
  ]) ++ (with pkgs.libsForQt5; [
    # From plasma5.
    dolphin
    dolphin-plugins
    ffmpegthumbs
    kdegraphics-thumbnailers
    kio
    kio-extras
    ark
  ]);

  home.pointerCursor = {
    package = pkgs.breeze-qt5;
    name = "breeze_cursors";
    size = 24; # Make cursor in each window the same size.
    gtk.enable = true;
    x11.enable = true;
  };

  gtk = {
    enable = true;
    theme = {
      package = pkgs.breeze-gtk;
      name = "Breeze-Dark";
    };
    iconTheme = {
      package = pkgs.breeze-icons;
      name = "breeze-dark";
    };
    font = {
      name = "Sans Serif Regular";
      size = 12; # This will be affected by text-scaling-factor. Dont scale here.
    };
    gtk2.configLocation = "${config.xdg.configHome}/gtk-2.0/gtkrc";
  };

  qt = {
    enable = true;
    platformTheme = "gnome";
    style.package = pkgs.breeze-qt5;
    style.name = "Breeze-dark"; # It should be `Breeze` but qtgnomeplatform needs a "-dark" postfix.
  };
  xdg.configFile."kdeglobals".source = "${pkgs.breeze-qt5}/share/color-schemes/BreezeDark.colors";

  wayland.windowManager.sway = {
    enable = true;
    xwayland = true;
    systemdIntegration = true;
    wrapperFeatures.gtk = true;

    package = my.pkgs.sway.override {
      withGtkWrapper = true;
    };

    config =
      let
        modifier = "Mod4";
        logoutMode = {
          name = "(l) lock, (e) logout, (s) suspend, (q) shutdown, (r) reboot";
          keys = {
            l = "mode default, exec loginctl lock-session";
            e = "mode default, exec 'systemctl --user stop graphical-session.target; swaymsg exit; loginctl terminate-session $XDG_SESSION_ID'";
            s = "mode default, exec systemctl suspend";
            q = "mode default, exec systemctl poweroff";
            r = "mode default, exec systemctl reboot";
            Escape = "mode default";
          };
        };
      in
      {
        terminal = "${terminal} -e ${pkgs.tmux}/bin/tmux new-session -t main";
        startup = [
          { command = "${my.pkgs.sway-systemd}/libexec/sway-systemd/assign-cgroups.py -l info"; }
          { command = "firefox"; }
          { command = "telegram-desktop"; }
          { command = "nheko"; }
          { command = "thunderbird"; }
        ];
        assigns = {
          "2" = [ { app_id = "firefox"; } ];
          "3" = [
            { app_id = "org.telegram.desktop"; }
            { app_id = "nheko"; }
          ];
          "4" = [ { app_id = "thunderbird"; } ];
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
        floating.criteria = [
          { app_id = "udiskie"; }
          { app_id = "org.kde.ark"; }
        ];

        gaps = {
          inner = 5;
          smartGaps = true;
          smartBorders = "on";
        };
        bars = [ ];

        # Don't break games. https://github.com/swaywm/sway/issues/6297
        seat."*".hide_cursor = "when-typing disable";

        input = {
          "*".xkb_options = "ctrl:nocaps";
          "1133:49298:Logitech_G102_LIGHTSYNC_Gaming_Mouse" = {
            accel_profile = "flat";
            pointer_accel = "0";
          };
        };
        output = {
          "*".background = "${my.pkgs.wallpaper} fill";
          # No scale! See ../wayland-dpi.nix
        };

        inherit modifier;
        keybindings =
          lib.mkOptionDefault {
            "${modifier}+s" = "split toggle";
            "${modifier}+b" = null;
            "${modifier}+v" = null;
            "${modifier}+w" = null;
            "${modifier}+d" = "exec ${rofi} -show drun";
            "${modifier}+Shift+d" = "exec ${rofi} -show run";
            "${modifier}+Shift+l" = "exec loginctl lock-session";
            "${modifier}+Shift+e" = "mode \"${logoutMode.name}\"";
            "${modifier}+space" = null;
            "Print" = ''
              exec 'grimshot save area - | tee "$XDG_PICTURES_DIR/screenshot-$(date +%Y-%m-%d-%H-%M-%S).png" | wl-copy --type image/png'
            '';
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

  programs.mako = {
    enable = true;
    defaultTimeout = 15000; # ms
    font = "sans-serif";
    extraConfig = ''
      on-button-right=exec ${pkgs.mako}/bin/makoctl menu -n "$id" ${rofi} -dmenu -p 'action: '
    '';
  };
  systemd.user.services.mako = {
    Unit = {
      Description = "Notification daemon for Wayland";
      Documentatio = "man:mako(1)";
      After = "graphical-session-pre.target";
      PartOf = "sway-session.target"; # Should be terminated when the session ends.
    };
    Service = {
      Slice = "session.slice";
      BusName = "org.freedesktop.Notifications";
      ExecStart = "${pkgs.mako}/bin/mako";
      Restart = "always";
    };
    Install.WantedBy = [ "sway-session.target" ];
  };

  programs.swaylock.settings = {
    daemonize = true;
    image = "${my.pkgs.wallpaper-blur}";
    scaling = "fill";
    # indicator-idle-visible = true;
    # clock = true;
    # datestr = "%Y-%m-%d %a";
    show-failed-attempts = true;
  };

  programs.rofi = {
    enable = true;
    package = pkgs.rofi-wayland;
    theme = "Arc-Dark";
    inherit terminal;
    extraConfig = {
      modi = "drun,run,ssh";
    };
  };

  services.udiskie = {
    enable = true;
    automount = false;
  };

  services.swayidle = {
    enable = true;
    timeouts = [
      {
        timeout = 900; # 15min
        command = "${swaylock}/bin/swaylock";
        # command = "${swaylock}/bin/swaylock --grace=5";
      }
      {
        timeout = 905;
        command = ''${sway}/bin/swaymsg "output * power off"'';
        resumeCommand = ''${sway}/bin/swaymsg "output * power on"'';
      }
    ];
    events = [
      {
        event = "lock";
        command = "${swaylock}/bin/swaylock";
      }
      # Not implemented yet: https://github.com/swaywm/swaylock/pull/237
      # { event = "unlock"; command = ""; }
      {
        event = "before-sleep";
        command = "/run/current-system/systemd/bin/loginctl lock-session";
      }
    ];
  };
  systemd.user.services.swayidle.Service.Slice = "session.slice";

  systemd.user.targets.sway-session.Unit.Wants = [
    "xdg-desktop-autostart.target"
  ];
}
