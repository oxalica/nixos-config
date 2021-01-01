{ ... }:
{
  xdg.userDirs = let prefix = "$HOME/.local/share/xdg"; in {
    enable = true;
    desktop = "$HOME/Desktop";
    download = "$HOME/Downloads";
    pictures = "$HOME/Pictures";
    documents = "$HOME/Misc";
    music = "$HOME/Misc";
    publicShare = "$HOME/Misc";
    templates = "$HOME/Misc";
    videos = "$HOME/Misc";
  };
}
