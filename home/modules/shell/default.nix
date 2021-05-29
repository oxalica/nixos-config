{ lib, pkgs, ... }:
{
  home.sessionVariables = {
    # Rust and python outputs.
    PATH = "$PATH\${PATH:+:}$HOME/.cargo/bin:$HOME/.local/bin";
  };

  programs.command-not-found.enable = true;

  programs.zsh = {
    enable = true;

    enableCompletion = true;
    enableAutosuggestions = true;

    history = {
      ignoreDups = true;
      ignoreSpace = true;
      share = true;

      ignorePatterns = [
        "rm *" "\\rm *"
        "sudo *rm*"
        "task *(append|add|delete|perge|done|modify)*"
      ];
    };

    initExtra = ''
      # Wordaround shortcut collision with Vim.
      bindkey "^e" backward-kill-word

      # For prompt.
      source ${pkgs.git}/share/git/contrib/completion/git-prompt.sh

      source ${./cmds.zsh}
      source ${pkgs.zsh-fast-syntax-highlighting}/share/zsh/site-functions/fast-syntax-highlighting.plugin.zsh
      FAST_HIGHLIGHT[use_async]=1 # Improve paste delay for nix store paths.

      eval "$(zoxide init zsh)"
    '';

    oh-my-zsh = {
      enable = true;
      theme = "avit_simple";
      custom = "${./.}";
      plugins = [];
    };
  };

  home.packages = let
    flake-zsh-completion = pkgs.runCommand "flake-nix-completion" {} ''
      install -Dm644 ${./_nix} $out/share/zsh/site-functions/_nix
    '';

    scripts = pkgs.runCommand "scripts" {
      inherit (pkgs) bash coreutils jq;
    } ''
      install -Dm755 -t $out/bin ${./scripts}/*.sh
      chmod -R +w $out
      for file in $out/bin/*.sh; do
        substituteAllInPlace "$file"
      done
    '';

  in [
    pkgs.zoxide
    (lib.hiPrio flake-zsh-completion)
    scripts
  ];
}
