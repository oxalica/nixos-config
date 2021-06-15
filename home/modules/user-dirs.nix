{ ... }:
{
  xdg.userDirs = let nouse = "$HOME/.local/share/user-dirs"; in {
    enable = true;
    desktop = nouse;
    download = "$HOME/Downloads";
    pictures = "$HOME/Pictures";
    documents = nouse;
    music = nouse;
    publicShare = nouse;
    templates = nouse;
    videos = nouse;
  };
}
