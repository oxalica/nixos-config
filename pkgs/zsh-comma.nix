# Ref: https://github.com/dramforever/config/blob/4ffe106a05cf38b5f776e0b7421efef0cdb80816/home/nixenv.zsh
{ lib, runCommandLocal, nix }:
runCommandLocal "zsh-comma" {
  plugin = ''
    typeset -g -a comma_paths

    ,() {
      setopt local_options err_return pipefail
      if [[ $# = 0 ]]; then
        printf "%s\n" $comma_paths
        return
      fi
      local -a ps
      ps=( $(nix build --json --no-link $@ | jq -r '.[].outputs[]') )
      ps=($^ps/bin)
      comma_paths+=($ps)
      path=($ps $path)
      export PATH
      printf "+%s paths, total %s paths\n" ''${#ps} ''${#comma_paths}
    }

    ,,() {
      path=(''${path:|comma_paths})
      comma_paths=()
      export PATH
    }
  '';

  completion = ''
    #compdef ,
    _,() {
      words[1]=(nix build)
      CURRENT+=1
      _nix
    }
  '';

  propagatedBuildInputs = [ nix.out ]; # Completion.

  meta.license = lib.licenses.mit;

} ''
  mkdir -p $out/share/zsh/{comma,site-functions}
  cat <<<"$plugin" >$out/share/zsh/comma/comma.zsh
  cat <<<"$completion" >$out/share/zsh/site-functions/_,
''
