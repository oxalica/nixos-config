{ pkgs, extensionFromMarket }:
with pkgs.vscode-extensions;

[
  bbenoist.Nix
  justusadam.language-haskell
  matklad.rust-analyzer
  ms-python.python
  ms-vscode-remote.remote-ssh
  ms-vscode.cpptools
  vadimcn.vscode-lldb
  vscodevim.vim

  # (extensionFromMarket { publisher = "vadimcn"; name = "vscode-lldb"; version = "1.5.0"; sha256 = "01792yzhf6alr0j0rxqsyh7v6lx9fiyinb0jar9rkfiwcdlq7a21"; })

  (extensionFromMarket { publisher = "alexcvzz"; name = "vscode-sqlite"; version = "0.6.0"; sha256 = "07sbrn9jsk0jnqqjn0f0zjhdgwbspzrmg3qazz3qrlwvr564qb14"; })
  (extensionFromMarket { publisher = "bungcip"; name = "better-toml"; version = "0.3.2"; sha256 = "08lhzhrn6p0xwi0hcyp6lj9bvpfj87vr99klzsiy8ji7621dzql3"; })
  (extensionFromMarket { publisher = "dbaeumer"; name = "vscode-eslint"; version = "1.9.0"; sha256 = "1lr25v236cz8kbgbgqj6izh3f4nwp9cxygpa0zzfvfrg8gg0x49w"; })
  (extensionFromMarket { publisher = "dramforever"; name = "vscode-ghc-simple"; version = "0.0.10"; sha256 = "13m28wjsakjszhlrl0i60rc6gs0xh9y9c0xpsmmym0x2q4ss6zfp"; })
  (extensionFromMarket { publisher = "eamodio"; name = "gitlens"; version = "9.4.1"; sha256 = "15a39p8wj84hypz0m25chrnqz3zyg4wjnx9z1vv3qqpppybqy2w8"; })
  (extensionFromMarket { publisher = "guidotapia2"; name = "unicode-math-vscode"; version = "0.2.5"; sha256 = "0c6021w0jr1hzl29i5ai973g10j209h0jkjv4bjcfakm0rqyp1ss"; })
  (extensionFromMarket { publisher = "jtr"; name = "vscode-position"; version = "1.0.1"; sha256 = "15jjjdhmqkvmg881pnrfn521khskdg5fk30wbakw1559fwmpnj2f"; })
  (extensionFromMarket { publisher = "ms-vscode"; name = "hexeditor"; version = "1.2.1"; sha256 = "01l5f2ia8g9csgcc3r2v7avcz03hagfpnq66hil1nhwkrlmqba3i"; })
  (extensionFromMarket { publisher = "serayuzgur"; name = "crates"; version = "0.4.7"; sha256 = "1r8ywmdiy7xxq27hkjglh29hvs0c2yz5g9x1laasp43sdi056spl"; })
  (extensionFromMarket { publisher = "webfreak"; name = "debug"; version = "0.22.0"; sha256 = "1frikakfcslwn177zdwzcc2qzvhvr7fw3whqls4hykhm577g093f"; })
  (extensionFromMarket { publisher = "zjhmale"; name = "idris"; version = "0.9.8"; sha256 = "1dfh1rgybhnf5driwgxh69a1inyzxl72njhq93qq7mhacwnyfsdp"; })
]
