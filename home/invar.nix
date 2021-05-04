{ pkgs, config, ... }:

{
  programs.home-manager.enable = true;

  imports = [
    ./modules/common-pkgs.nix
    ./modules/firefox.nix
    ./modules/git.nix
    ./modules/gpg.nix
    ./modules/mail.nix
    ./modules/mkX-backup.nix
    ./modules/rime-fcitx.nix
    ./modules/rust.nix
    ./modules/shell
    ./modules/stretchly.nix
    ./modules/tmux.nix
    ./modules/trash.nix
    ./modules/user-dirs.nix
    ./modules/vim
    ./modules/vscode

    ./plugins/hm-desktop-autostart.nix
  ];

  fonts.fontconfig.enable = true;

  home.file = let
    home = config.home.homeDirectory;
    link = path: config.lib.file.mkOutOfStoreSymlink "${home}/${path}";
    linkPersonal = path: link "storage/personal/${path}";
  in {
    ".local/share/fcitx5/rime/sync".source = linkPersonal "rime-sync";
    ".local/share/osu".source = linkPersonal "game/osu-lazer";
    ".local/share/password-store".source = linkPersonal "password-store"; # FIXME: Put it in settings?
    ".gnupg".source = linkPersonal "gnupg"; # FIXME: `passff` doesn't get `GNUPGHOME`.
    ".ssh".source = linkPersonal "ssh";
    ".taskrc".source = linkPersonal "task/taskrc";
  };

  programs.gpg.homedir = "${config.home.homeDirectory}/storage/personal/gnupg";

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "20.03";
}
