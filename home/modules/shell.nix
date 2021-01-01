{ ... }:
{
  home.sessionVariables = {
    # Rust and python outputs.
    PATH = "$PATH\${PATH:+:}$HOME/.cargo/bin:$HOME/.local/bin";
  };

  programs.zsh = {
    enable = true;
    shellAliases = {
      py = "python";
      rm = "echo \"No, you shouldn't rm\"";
    };
  };
}
