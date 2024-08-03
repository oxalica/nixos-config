{ pkgs, my, ... }:
{
  programs.git = {
    enable = true;

    ignores = [
      # vim swap files.
      "*~" "*.swp"

      # Editor local settings.
      ".vim/coc-settings.json"
      ".vscode"

      # Environments
      ".envrc"
    ];

    aliases = {
      br = "branch";
      cmt = "commit";
      co = "checkout";
      cp = "cherry-pick";
      d = "diff";
      dc = "diff --cached";
      dt = "difftool";
      l = "log";
      mt = "mergetool";
      st = "status";
      sub = "submodule";
    };

    extraConfig = {
      # User & signing.
      user.name = "oxalica";
      user.email = "oxalicc@pm.me";
      user.signingKey = my.gpg.fingerprint;
      tag.gpgSign = true;

      # Pull.
      pull.ff = "only";

      # Rebase.
      rebase.autoSquash = true;
      rebase.abbreviateCommands = true;

      # Diff & merge.
      diff.external = "${pkgs.difftastic}/bin/difft";
      diff.tool = "nvimdiff";
      difftool.prompt = false;
      merge.tool = "nvimdiff";
      merge.conflictstyle = "diff3";
      mergetool.prompt = false;
      rerere.enabled = true;

      # Pager.
      core.pager = "less";
      pager.branch = "less --quit-if-one-screen";
      pager.stash = "less --quit-if-one-screen";

      # Display.
      # Always show branches and tags for `git log` in `vim-fugitive`.
      # See: https://github.com/tpope/vim-fugitive/issues/1965
      log.decorate = true;
      # Show detailed diff by default for `git stash show`.
      stash.showPatch = true;

      # Misc.
      init.defaultBranch = "main";
      push.autoSetupRemote = true;
      advice.detachedHead = false;
    };
  };
}
