{ ... }:
{
  programs.git = {
    enable = true;
    signing.signByDefault = true;

    userName = "oxalica";
    userEmail = "oxalicc@pm.me";
    signing.key = "5CB0E9E5D5D571F57F540FEACED392DE0C483D00";

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
      pull.ff = "only";
      advice.detachedHead = false;

      diff.tool = "vimdiff";
      difftool.prompt = false;

      merge.tool = "vimdiff";
      merge.conflictstyle = "diff3";
      mergetool.prompt = false;
    };
  };
}
