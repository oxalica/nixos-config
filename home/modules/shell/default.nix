{ lib, pkgs, config, ... }:
{
  home.sessionVariables = {
    # Rust and python outputs.
    PATH = "$PATH\${PATH:+:}$HOME/.cargo/bin:$HOME/.local/bin";
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

  home.packages = let
    scripts = pkgs.runCommand "scripts" {
      inherit (pkgs) bash coreutils jq;
    } ''
      install -Dm755 -t $out/bin ${./scripts}/*.sh
      chmod -R +w $out
      for file in $out/bin/*.sh; do
        substituteAllInPlace "$file"
      done
    '';

    termcolors = pkgs.runCommand "termcolors" {
      src = pkgs.fetchurl {
        url = "https://gist.githubusercontent.com/lilydjwg/fdeaf79e921c2f413f44b6f613f6ad53/raw/94d8b2be62657e96488038b0e547e3009ed87d40/colors.py";
        hash = "sha256-l/RTPZp2v7Y4ffJRT5Fy5Z3TDB4dvWfE7wqMbquXdJA=";
      };
      nativeBuildInputs = [ pkgs.python3 ];
    } ''
      install -Dm555 $src $out/bin/termcolors
      patchShebangs $out/bin
    '';

  in with pkgs; [
    zoxide
    nix-zsh-completions
    (lib.hiPrio nixFlakes) # Prefer nix's builtin completion.
    fzf bat # WARN: They are used by fzf.vim!

    scripts
    termcolors
  ];
}
