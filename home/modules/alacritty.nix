{ pkgs, ... }:
{
  programs.alacritty = {
    enable = true;

    # https://alacritty.org/config-alacritty.html
    settings = {
      import = [
        "${pkgs.vimPlugins.nightfox-nvim}/extra/nightfox/alacritty.toml"
      ];

      window.padding = { x = 4; y = 0; };
      # window.startup_mode = "Fullscreen";
      window.startup_mode = "Maximized";

      scrolling.history = 1000; # Should not matter since we have tmux.
      scrolling.multiplier = 5;

      font.size = 12;

      # Set initial command on shortcuts, not for all alacritty.
      # `shell.program` is NOT set here.

      mouse.hide_when_typing = true;
    };
  };
}
