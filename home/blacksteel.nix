{ lib, pkgs, config, ... }:

{
  programs.home-manager.enable = true;

  imports = [
    ./modules/wayland-dpi.nix

    ./modules/alacritty.nix
    ./modules/direnv.nix
    ./modules/firefox.nix
    ./modules/git.nix
    ./modules/gpg.nix
    ./modules/lf.nix
    ./modules/mail.nix
    ./modules/mime-apps.nix
    ./modules/nvim
    ./modules/programs.nix
    ./modules/rime-fcitx.nix
    ./modules/rust.nix
    ./modules/shell
    ./modules/task.nix
    ./modules/tmux.nix
    ./modules/user-dirs.nix
  ];

  programs.alacritty.settings.font.size = lib.mkForce 10;

  home.file = let
    home = config.home.homeDirectory;
    link = path: config.lib.file.mkOutOfStoreSymlink "${home}/${path}";
    linkPersonal = path: link "storage/personal/${path}";
  in {
    ".local/share/fcitx5/rime/sync".source = linkPersonal "rime-sync";
    ".local/share/password-store".source = linkPersonal "password-store";
    ".local/share/task".source = linkPersonal "taskwarrior";
  };

  xdg.enable = true;

  home.stateVersion = "22.11";
}
