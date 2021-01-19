{ lib, pkgs, ... }:
{
  home.sessionVariables = {
    # Rust and python outputs.
    PATH = "$PATH\${PATH:+:}$HOME/.cargo/bin:$HOME/.local/bin";
  };

  programs.zsh = {
    enable = true;

    enableCompletion = true;
    enableAutosuggestions = true;

    history = {
      ignoreDups = true;
      ignoreSpace = true;
      share = true;
    };

    initExtra = ''
      # For prompt.
      source ${pkgs.git}/share/git/contrib/completion/git-prompt.sh

      source ${./cmds.zsh}
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

  in [
    z-man
    (lib.hiPrio flake-zsh-completion)
  ];
}
