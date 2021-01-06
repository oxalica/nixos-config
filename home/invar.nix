{ pkgs, config, ... }:

{
  programs.home-manager.enable = true;
  # home.file."nix".source = config.lib.file.mkOutOfStoreSymlink ./.;

  imports = [
    ./modules/rust-nightly-monitor.nix

    ./modules/shell
    ./modules/vim
    ./modules/vscode
    ./modules/common-pkgs.nix
    ./modules/git.nix
    ./modules/gpg.nix
    ./modules/mail.nix
    ./modules/mkX-backup.nix
    ./modules/rime-fcitx.nix
    ./modules/rust.nix
    ./modules/ssh-scut0.nix
    ./modules/trash.nix
    ./modules/user-dirs.nix

    ./plugins/hm-desktop-autostart.nix
  ];

  fonts.fontconfig.enable = true;

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
