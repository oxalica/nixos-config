{ vimUtils, fetchFromGitHub }:
vimUtils.buildVimPlugin {
  name = "lsp-inlayhints.nvim";
  version = "unstable-2022-07-30";
  src = fetchFromGitHub {
    owner = "lvimuser";
    repo = "lsp-inlayhints.nvim";
    rev = "0df2f61a15ab60e89a39173c8e49e0338ed39e73";
    hash = "sha256-qmQvLF6LwrWXUMQdiIBStZn+udLZSsab/75fikbcVGA=";
  };
}
