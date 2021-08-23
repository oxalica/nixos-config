{ pkgs, ... }:
let
  cocSettings = {
    # "rust-analyzer.enable" = false; # Disable by default.
    "rust-analyzer.server.path" = "${pkgs.rust-analyzer}/bin/rust-analyzer";
  };

  cocConfigHome = pkgs.writeTextFile {
    name = "coc-config-home";
    destination = "/coc-settings.json";
    text = builtins.toJSON cocSettings;
  };

  plugins = with pkgs.vimPlugins; [
    easymotion
    # fcitx-vim
    nerdcommenter
    rust-vim
    vim-beancount
    vim-cursorword
    vim-gitgutter
    vim-nix
    vim-sandwich
    vim-toml

    coc-nvim
    coc-rust-analyzer

    # FIXME
    (fcitx-vim.overrideAttrs (old: {
      version = "2021-08-20";
      src = pkgs.fetchFromGitHub {
        owner = "lilydjwg";
        repo = "fcitx.vim";
        rev = "3554b279a09f0edf31129ad162613e5954097fd0";
        hash = "sha256-kIHPbtmOnttxzJwd8e1L0Lb8It0d+KgrtIQswzX1Eq4=";
      };
    }))

    (pkgs.vimUtils.buildVimPlugin {
      name = "lilypink";
      src = ./lilypink;
    })
  ];

  extraConfig = ''
    source ${./init.vim}

    " Plugin settings

    " coc-nvim
    let g:coc_start_at_startup=has('nvim')
    let g:coc_config_home='${cocConfigHome}'
    inoremap <silent><expr> <c-@> coc#refresh()
    inoremap <silent><expr> <cr> pumvisible() ? coc#_select_confirm() : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

    " coc-rust-analyzer
    " let g:rustfmt_autosave = 1

    " nerdcommenter
    let g:NERDSpaceDelims = 1
    let g:NERDDefaultAlign = 'left'
    let g:NERDCommentEmptyLines = 1

    " vim-sandwich
    runtime START **/sandwich/keymap/surround.vim
    " Use behavior of vim-surround for left parenthesis input. https://github.com/machakann/vim-sandwich/issues/44
    let g:sandwich#recipes += [
      \   {'buns': ['{ ', ' }'], 'nesting': 1, 'match_syntax': 1, 'kind': ['add', 'replace'], 'action': ['add'], 'input': ['{']},
      \   {'buns': ['[ ', ' ]'], 'nesting': 1, 'match_syntax': 1, 'kind': ['add', 'replace'], 'action': ['add'], 'input': ['[']},
      \   {'buns': ['( ', ' )'], 'nesting': 1, 'match_syntax': 1, 'kind': ['add', 'replace'], 'action': ['add'], 'input': ['(']},
      \   {'buns': ['{\s*', '\s*}'],   'nesting': 1, 'regex': 1, 'match_syntax': 1, 'kind': ['delete', 'replace', 'textobj'], 'action': ['delete'], 'input': ['{']},
      \   {'buns': ['\[\s*', '\s*\]'], 'nesting': 1, 'regex': 1, 'match_syntax': 1, 'kind': ['delete', 'replace', 'textobj'], 'action': ['delete'], 'input': ['[']},
      \   {'buns': ['(\s*', '\s*)'],   'nesting': 1, 'regex': 1, 'match_syntax': 1, 'kind': ['delete', 'replace', 'textobj'], 'action': ['delete'], 'input': ['(']},
      \ ]
  '';

in
{
  programs.vim = {
    enable = true;
    inherit extraConfig plugins;
  };

  programs.neovim = {
    enable = true;
    inherit extraConfig plugins;
  };
}
