{ pkgs }:

{
  "update.mode" = "manual";
  "workbench.startupEditor" = "none";
  "workbench.list.keyboardNavigation" = "filter";
  "explorer.confirmDragAndDrop" = false;

  "extensions.autoUpdate" = false;
  "window.titleBarStyle" = "native";
  "window.menuBarVisibility" = "toggle";

  "editor.fontFamily" = "'Sarasa mono SC'";
  "editor.fontSize" = 16;
  "editor.fontLigatures" = true;

  "editor.detectIndentation" = true;
  "editor.insertSpaces" = true;
  "editor.tabSize" = 4;
  "files.encoding" = "utf8";
  "files.autoGuessEncoding" = false;

  "files.insertFinalNewline" = true;
  "files.trimFinalNewlines" = true;
  "files.trimTrailingWhitespace" = true;

  "[haskell]"."editor.tabSize" = 2;
  "[html]"."editor.tabSize" = 2;
  "[idris]"."editor.tabSize" = 2;
  "[javascript]"."editor.tabSize" = 2;
  "[nix]"."editor.tabSize" = 2;
  "[typescript]"."editor.tabSize" = 2;

  "[rust]"."editor.formatOnSave" = true; # break codes?

  # Don't break patch files.
  "[diff]" = {
    "editor.renderWhitespace" = "boundary";
    "files.insertFinalNewline" = true;
    "files.trimFinalNewlines" = false;
    "files.trimTrailingWhitespace" = false;
  };

  "[makefile]" = {
    "editor.renderWhitespace" = "boundary";
    "editor.insertSpaces" = false;
  };

  "python.linting.enabled" = true;
  "python.linting.pylintEnabled" = true;
  "python.linting.pylintPath" = "${pkgs.python3Packages.pylint}/bin/pylint";

  "javascript.format.insertSpaceBeforeFunctionParenthesis" = true;
  "javascript.format.insertSpaceAfterConstructor" = true;
  "javascript.preferences.quoteStyle" = "single";
  "typescript.format.insertSpaceBeforeFunctionParenthesis" = true;
  "typescript.format.insertSpaceAfterConstructor" = true;
  "typescript.preferences.quoteStyle" = "single";

  "vim.autoindent" = true;
  "vim.surround" = true;
  "vim.easymotion" = true;
  "vim.normalModeKeyBindingsNonRecursive" = [
    {
      "before" = ["<enter>"];
      "commands" = [":set hlsearch!"];
    }
  ];
  "vim.visualModeKeyBindingsNonRecursive" = [
    {
      "before" = ["<c-c>"];
      "after" = [
        "\"" "+" "y"
        "g" "v"
      ];
    }
  ];

  "git.terminalAuthentication" = false;
}
