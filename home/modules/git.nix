{ my, ... }:
{
  programs.git = {
    enable = true;

    userName = "oxalica";
    userEmail = "oxalicc@pm.me";

    signing.signByDefault = false;
    signing.key = my.gpg.fingerprint;

    ignores = [ "*~" "*.swp" ]; # vim swap file

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
      init.defaultBranch = "main";

      pull.ff = "only";
      advice.detachedHead = false;

      diff.tool = "nvimdiff";
      difftool.prompt = false;

      merge.tool = "nvimdiff";
      merge.conflictstyle = "diff3";
      mergetool.prompt = false;

      core.pager = "less";
      pager.branch = "less --quit-if-one-screen";
      pager.stash = "less --quit-if-one-screen";
    };
  };
}
