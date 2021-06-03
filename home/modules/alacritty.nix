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

      font.normal.family = "Sarasa Mono SC";
      font.size = 12;

      shell.program = "tmux";
    };
  };
}

