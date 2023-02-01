{ pkgs, config, my, ... }:
{
  programs.alacritty = {
    enable = true;
    package = my.pkgs.alacritty-fractional-scale;

    # https://github.com/alacritty/alacritty/blob/master/alacritty.yml
    settings = {
      import = [
        "${pkgs.vimPlugins.nightfox-nvim}/extra/dayfox/nightfox_alacritty.yml"
      ];

      window.padding = { x = 4; y = 0; };
      # window.startup_mode = "Fullscreen";
      window.startup_mode = "Maximized";

      scrolling.history = 1000; # Should not matter since we have tmux.
      scrolling.multiplier = 5;

      font.size = 12 * config.wayland.dpi / 96;

      # Set initial command on shortcuts, not for all alacritty.
      # shell.program = "${pkgs.tmux}/bin/tmux";

      mouse.hide_when_typing = true;
    };
  };
}
