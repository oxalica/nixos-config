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

      mkdir -p "$HOME/.local/share/z"
      _Z_DATA="$HOME/.local/share/z/z"
    '';

    oh-my-zsh = {
      enable = true;
      theme = "avit_simple";
      custom = "${./.}";
      plugins = [
        "z"
      ];
    };
  };

  home.packages = let
    flake-zsh-completion = pkgs.runCommand "flake-nix-completion" {} ''
      install -Dm644 ${./_nix} $out/share/zsh/site-functions/_nix
    '';

    z-man = pkgs.stdenv.mkDerivation {
      name = "z-man";
      inherit (pkgs.oh-my-zsh) src;
      dontConfigure = true;
      dontBuild = true;
      installPhase = "install -Dm644 -t $out/share/man/man1 ./plugins/z/z.1";
    };

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
    z-man
    (lib.hiPrio flake-zsh-completion)
    scripts
  ];
}
