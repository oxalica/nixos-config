{ pkgs, config, ... }:

{
  programs.home-manager.enable = true;

  imports = [
    ./modules/alacritty.nix
    ./modules/common-pkgs.nix
    ./modules/direnv.nix
    ./modules/firefox.nix
    ./modules/git.nix
    ./modules/gpg.nix
    ./modules/helix
    ./modules/lf.nix
    ./modules/mail.nix
    ./modules/nvim
    ./modules/rime-fcitx.nix
    ./modules/rust.nix
    ./modules/shell
    ./modules/stretchly.nix
    ./modules/sway
    ./modules/task.nix
    ./modules/tmux.nix
    ./modules/trash.nix
    ./modules/user-dirs.nix
  ];

  xdg.enable = true;

  programs.zsh.loginExtra = ''
    if [[ -z $DISPLAY && "$(tty)" = /dev/tty1 ]] && type sway >/dev/null; then
      exec sway
    fi
  '';

  systemd.user.sessionVariables = {
    inherit (config.home.sessionVariables) CARGO_HOME GNUPGHOME PASSWORD_STORE_DIR;
    GTK_USE_PORTAL = 1; # Use KDE's file picker.
  };

  home.file = let
    home = config.home.homeDirectory;
    link = path: config.lib.file.mkOutOfStoreSymlink "${home}/${path}";
    linkPersonal = path: link "storage/personal/${path}";
  in {
    ".local/share/fcitx5/rime/sync".source = linkPersonal "rime-sync";
    ".local/share/osu".source = linkPersonal "game/osu-lazer";
    ".local/share/password-store".source = linkPersonal "password-store";
    ".local/share/task".source = linkPersonal "taskwarrior";
    ".ssh".source = linkPersonal "ssh";
  };

  programs.gpg.homedir = "${config.home.homeDirectory}/storage/personal/gnupg";

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

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "21.05";
}
