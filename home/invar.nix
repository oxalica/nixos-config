{
  lib,
  pkgs,
  config,
  ...
}:

{
  imports = [
    ./modules/alacritty.nix
    ./modules/direnv.nix
    ./modules/firefox.nix
    ./modules/git.nix
    ./modules/gpg.nix
    ./modules/helix
    ./modules/lf.nix
    ./modules/mail.nix
    ./modules/nvim
    ./modules/programs.nix
    ./modules/rime-fcitx.nix
    ./modules/rust.nix
    ./modules/shell
    ./modules/tmux.nix
    ./modules/user-dirs.nix
    ./modules/vscode
  ];

  # For Xwayland apps, ie. electron and steam.
  xresources.properties."Xft.dpi" = 120;
  # NB. The Xresources is not loaded automatically outside an X session.
  systemd.user.services."load-xresources" = {
    Unit.Description = "Load user X resources from '~/.Xresources'";
    Service.Type = "oneshot";
    Service.ExecStart = "${lib.getExe pkgs.xorg.xrdb} -load ${config.xresources.path}";
    Unit.After = [ "plasma-kwin_wayland.service" ];
    Install.WantedBy = [ "graphical-session.target" ];
  };

  xdg.enable = true;

  home.file =
    let
      link = path: config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/${path}";
    in
    {
      ".local/share/password-store".source = link "storage/5x-state/51-secret/51.10-password-store";
      ".local/share/fcitx5/rime/sync".source = link "storage/5x-state/55-backup/55.06-rime-directory";
    };

  systemd.user.services."rime-sync" = {
    Unit.Description = "Export rime dictionary";
    # https://github.com/fcitx/fcitx5-rime/issues/28#issuecomment-828484970
    Service.ExecStart = ''${pkgs.qt5.qttools.bin}/bin/qdbus org.fcitx.Fcitx5 /controller org.fcitx.Fcitx.Controller1.SetConfig "fcitx://config/addon/rime/sync" ""'';
  };
  systemd.user.timers."rime-sync" = {
    Timer = {
      OnCalendar = "*-*-* 03:00:00";
      Persistent = true;
    };
    Install.WantedBy = [ "timers.target" ];
  };

  home.stateVersion = "24.11";
}
