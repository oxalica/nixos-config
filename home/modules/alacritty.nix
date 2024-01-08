{ pkgs, config, ... }:
{
  programs.alacritty = {
    enable = true;

    # https://github.com/alacritty/alacritty/blob/master/alacritty.yml
    settings = {
      import = [
        # Workaround: https://github.com/EdenEast/nightfox.nvim/issues/399
        (pkgs.runCommandNoCC "nightfox_alacritty.toml" { } ''
          ${pkgs.yj}/bin/yj -yt <"${pkgs.vimPlugins.nightfox-nvim}/extra/nightfox/nightfox_alacritty.yml" >$out
        '')
      ];

      window.padding = { x = 4; y = 0; };
      # window.startup_mode = "Fullscreen";
      window.startup_mode = "Maximized";

      scrolling.history = 1000; # Should not matter since we have tmux.
      scrolling.multiplier = 5;

      font.size = 12 * config.wayland.dpi / 96;

      # Set initial command on shortcuts, not for all alacritty.
      # `shell.program` is NOT set here.

      mouse.hide_when_typing = true;
    };
  };
}
