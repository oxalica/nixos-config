{ lib, pkgs, config, ... }:
{
  home.sessionVariables = {
    # Rust and python outputs.
    PATH = "$PATH\${PATH:+:}$HOME/.cargo/bin:$HOME/.local/bin";

    FZF_DEFAULT_COMMAND = "${lib.getBin pkgs.fd}/bin/fd";
    FZF_DEFAULT_OPTS = lib.concatStringsSep " " [
      "--layout=reverse"
      "--info=inline"
      "--preview-window=down"
      "--bind=ctrl-p:up,ctrl-n:down,up:previous-history,down:next-history"
    ];
  };

  # The default `command-not-found` relies on nix-channel. Use `nix-index` instead.
  programs.command-not-found.enable = false;
  programs.nix-index.enable = true;

  programs.zsh = {
    enable = true;

    dotDir = ".config/zsh";

    enableCompletion = false; # We do it ourselves.

    history = {
      ignoreDups = true;
      ignoreSpace = true;
      expireDuplicatesFirst = true;
      extended = true;
      share = true;
      path = "${config.xdg.dataHome}/zsh/zsh_history";
      save = 10000;
      size = 50000;
      ignorePatterns = [
        "rm *" "\\rm *"
        "sudo *rm*"
        "task *(append|add|delete|perge|done|modify)*"
      ];
    };

    initExtra = ''
      # Random settings.
      setopt interactivecomments
      setopt hist_verify
      setopt auto_pushd
      export LS_COLORS="rs=0:di=01;34:ln=01;36:mh=00:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:mi=00:su=37;41:sg=30;43:ca=30;41:tw=30;42:ow=34;42:st=37;44:ex=01;32:"
      autoload -U compinit

      # Init.
      source ${pkgs.git}/share/git/contrib/completion/git-prompt.sh
      source ${./prompt.zsh}
      source ${./cmds.zsh}
      source ${./key-bindings.zsh}
      source ${./completion.zsh}

      # Plugins.
      source ${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh
      source ${pkgs.zsh-fast-syntax-highlighting}/share/zsh/site-functions/fast-syntax-highlighting.plugin.zsh
      FAST_HIGHLIGHT[use_async]=1 # Improve paste delay for nix store paths.
      eval "$(zoxide init zsh)"
    '';
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

  in with pkgs; [
    zoxide
    nix-zsh-completions
    (lib.hiPrio flake-zsh-completion)
    fzf

    scripts
  ];
}
