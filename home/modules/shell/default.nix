{ lib, pkgs, config, my, ... }:
{
  home.sessionVariables = {
    # Rust and python outputs.
    PATH = "$HOME/.local/bin\${PATH:+:}$PATH";

    FZF_DEFAULT_COMMAND = "${lib.getBin pkgs.fd}/bin/fd --type=f --hidden --no-ignore-vcs --exclude=.git";
    FZF_DEFAULT_OPTS = lib.concatStringsSep " " [
      "--layout=reverse" # Top-first.
      "--color=16" # 16-color theme.
      "--info=inline"
      "--bind=ctrl-p:up,ctrl-n:down,up:previous-history,down:next-history,alt-p:toggle-preview,alt-a:select-all"
      "--exact" # Substring matching by default, `'`-quote for subsequence matching.
    ];
  };

  # The default `command-not-found` relies on nix-channel. Use `nix-index` instead.
  programs.command-not-found.enable = false;
  programs.nix-index = {
    enable = true;
    # Don't install the hook.
    enableBashIntegration = false;
    enableZshIntegration = false;
  };

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
      path = "${config.xdg.stateHome}/zsh/history";
      save = 10000;
      size = 50000;
      ignorePatterns = [
        "rm *" "\\rm *"
        "sudo *rm*"
        "task *(append|add|delete|perge|done|modify)*"
      ];
    };

    # bash
    initExtra = ''
      # Random settings.
      setopt interactivecomments
      setopt hist_verify
      setopt auto_pushd
      export LS_COLORS="rs=0:di=01;34:ln=01;36:mh=00:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:mi=00:su=37;41:sg=30;43:ca=30;41:tw=30;42:ow=34;42:st=37;44:ex=01;32:"

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

  home.packages = with pkgs; [
    zoxide
    nix nix-zsh-completions # Prefer nix's builtin completion.
    fzf bat # WARN: They are used by fzf.vim!
    my.pkgs.colors
  ];
}
