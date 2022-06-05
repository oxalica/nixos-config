{
  programs.lf = {
    enable = true;

    settings = {
      scrolloff = 5;
    };

    keybindings = {
      # Mouse.
      "<m-up>" = "scroll-up";
      "<m-down>" = "scroll-down";

      "<delete>" = "delete";
      D = "delete";
      x = "cut";
      "<c-h>" = "set hidden!";
    };

    extraConfig = ''
      set mouse
      set scrolloff 5
    '';
  };
}
