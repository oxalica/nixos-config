{ pkgs, config, ... }:

{
  programs.home-manager.enable = true;

  imports = [
    ./modules/wayland-dpi.nix

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
    ./modules/sway
    ./modules/task.nix
    ./modules/tmux.nix
    ./modules/user-dirs.nix
  ];

  wayland.dpi = 120;

  xdg.enable = true;

  home.file = let
    link = path: config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/${path}";
  in {
    ".local/share/task".source = link "storage/0x-system/02-todo/02.01-taskwarrior";
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

  home.stateVersion = "23.11";
}
