{ pkgs, ... }:
{
  programs.alacritty = {
    enable = true;

    # https://github.com/alacritty/alacritty/blob/master/alacritty.yml
    settings = {
      window.padding = { x = 4; y = 0; };
      # window.startup_mode = "Fullscreen";
      window.startup_mode = "Maximized";

      scrolling.history = 1000; # Should not matter since we have tmux.
      scrolling.multiplier = 5;

      font.size = 12;

      # Set initial command on shortcuts, not for all alacritty.
      # shell.program = "${pkgs.tmux}/bin/tmux";

      mouse.hide_when_typing = true;
    };
  };

  home.packages = [
    # Jun 04 07:49:35 invar kglobalaccel5[2299]: kf.globalaccel.kglobalacceld: No desktop file found for service "alacritty.desktop"
    (pkgs.runCommand "alacritty-desktop" {} ''
      mkdir -p $out/share/applications
      cp ${pkgs.alacritty}/share/applications/Alacritty.desktop $out/share/applications/alacritty.desktop
      sed 's/Name=Alacritty/Name=alacritty/g' --in-place $out/share/applications/alacritty.desktop
    '')
  ];
}

