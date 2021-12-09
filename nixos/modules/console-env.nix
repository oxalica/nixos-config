{ lib, pkgs, ... }:
{
  # Reduce closure size.
  i18n.supportedLocales = lib.mkDefault [ "en_US.UTF-8/UTF-8" ];
  i18n.defaultLocale = lib.mkDefault "en_US.UTF-8";

  programs.less.enable = true;
  # Override the default value in nixos/modules/programs/environment.nix
  environment.variables.PAGER = "less";
  # Don't use `programs.less.envVariables.LESS`, which will be override by `LESS` set by `man`.
  environment.variables.LESS = lib.concatStringsSep " " [
    "--RAW-CONTROL-CHARS" # Only allow colors.
    "--mouse"
    "--wheel-lines=5"
  ];

  environment.systemPackages = with pkgs; [
    procs ncdu swapview smartmontools # Stat
    pv exa fd ripgrep lsof jq loop bc file rsync dnsutils # Utilities
    gnupg age pwgen # Crypto
    libarchive # Compression
  ];

  programs.tmux.enable = true;

  programs.htop.enable = true;
  programs.iotop.enable = true;
  programs.iftop.enable = true;

  # Minimal Vim config.
  programs.vim.defaultEditor = true;
  programs.vim.package = pkgs.vim_configurable.customize {
    name = "vim";
    # vim
    vimrcConfig.customRC = ''
      " Core.
      set mouse=a
      set scrolloff=5

      " Encoding.
      set encoding=utf-8 termencoding=utf-8
      set fileencodings=ucs-bom,utf-8,gb18030,default

      " Input.
      set shiftwidth=4 softtabstop=4
      set autoindent smarttab expandtab
      set ttimeoutlen=1

      " Render.
      set number
      set cursorline
      syntax on

      " XDG.
      if empty($XDG_STATE_HOME)
        let $XDG_STATE_HOME = $HOME . "/.local/state"
      endif
      set viminfofile=$XDG_STATE_HOME/vim/viminfo

      " Mapping.
      command -nargs=0 Sudow w !sudo tee % >/dev/null
    '';
  };
}
