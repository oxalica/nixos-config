{ lib, pkgs, config, my, ... }:
{
  home.sessionVariables = {
    # Rust and python outputs.
    PATH = "$HOME/.local/bin\${PATH:+:}$PATH";

    FZF_DEFAULT_COMMAND = "${lib.getBin pkgs.fd}/bin/fd --type=f --hidden --exclude=.git";
    FZF_DEFAULT_OPTS = lib.concatStringsSep " " [
      "--layout=reverse" # Top-first.
      "--color=16" # 16-color theme.
      "--info=inline"
      "--exact" # Substring matching by default, `'`-quote for subsequence matching.
      "--bind=alt-p:toggle-preview,alt-a:select-all"
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

    # Disable /etc/{zshrc,zprofile} that contains the "sane-default" setup.
    # See `/etc/zshrc` for more info.
    envExtra = ''
      setopt no_global_rcs
    '';

    enableAutosuggestions = true;
    enableCompletion = false; # We do it ourselves.
    enableVteIntegration = true;

    history = {
      ignoreDups = true;
      ignoreSpace = true;
      expireDuplicatesFirst = true;
      extended = true;
      share = true;
      path = "${config.xdg.stateHome}/zsh/history";
      save = 1000000;
      size = 1000000;
      ignorePatterns = [
        "rm *" "\\rm *"
        "sudo *rm*"
        "task *(append|add|delete|perge|done|modify)*"
      ];
    };

    # Ref: https://blog.quarticcat.com/zh/posts/how-do-i-make-my-zsh-smooth-as-fuck/
    # bash
    initExtra = ''
      setopt auto_pushd
      setopt hist_verify
      setopt interactive_comments
      setopt multios
      setopt noextended_glob # Breaks flake path reference nixpkgs#foo.
      export LS_COLORS='rs=0:di=01;34:ln=01;36:mh=00:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:mi=00:su=37;41:sg=30;43:ca=30;41:tw=30;42:ow=34;42:st=37;44:ex=01;32:'
      TIMEFMT=$'%J  %uU user %uS system %uE/%*E elapsed %PCPU (%Xavgtext+%Davgdata %Mmaxresident)k\n%Iinputs+%Ooutputs (%Fmajor+%Rminor)pagefaults %Wswaps'

      source ${pkgs.git}/share/git/contrib/completion/git-prompt.sh
      source ${./prompt.zsh}
      source ${./cmds.zsh}
      source ${./key-bindings.zsh}
      source ${./completion.zsh}

      ZSH_AUTOSUGGEST_MANUAL_REBIND=1
      ZSH_AUTOSUGGEST_HISTORY_IGNORE=$'*\n*'
      source ${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh
      source ${pkgs.zsh-fast-syntax-highlighting}/share/zsh/site-functions/fast-syntax-highlighting.plugin.zsh
      FAST_HIGHLIGHT[use_async]=1 # Improve paste delay for nix store paths.
      source ${pkgs.fzf}/share/fzf/key-bindings.zsh
    '';
  };

  programs.zoxide.enable = true;

  home.packages = with pkgs; [
    nix nix-zsh-completions # Prefer nix's builtin completion.
    fzf bat # WARN: They are used by fzf.vim!
    my.pkgs.colors
  ];
}
