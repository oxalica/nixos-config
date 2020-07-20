{ ... }:
{
  programs.zsh = {
    enable = true;

    enableCompletion = true;
    autosuggestions.enable = true;
    setOptions = [ "HIST_IGNORE_DUPS" "HIST_IGNORE_SPACE" "HIST_FCNTL_LOCK" ];
    interactiveShellInit = builtins.readFile ./interactive.zsh;

    ohMyZsh = {
      enable = true;
      theme = "avit";
      plugins = [
        "z"
        "git"
      ];
    };
  };

  # Already set as functions in init script.
  # Need to override oh-my-zsh settings.
  environment.shellAliases = {
    l = "l";
    ls = "ls";
    ll = "ll";
  };
}
