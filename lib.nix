{ lib }:
{
  # TODO: Wait for https://github.com/NixOS/nixpkgs/pull/243390
  toTOML = let
    inherit (builtins) toJSON concatStringsSep isAttrs isList isFloat;
    inherit (lib) isStringLike concatMapStringsSep mapAttrsToList;

    # We use `toJSON` for serialization of string, numbers and booleans.
    # The only incompatibility is that JSON allows `"\/"` while TOML does not.
    # But `builtins.toJSON` does not escape `/` anyway, so it's fine.

    inf = 1.0e308 * 10;

    toTopLevel = obj:
      concatStringsSep ""
        (mapAttrsToList
          (name: value: "${toJSON name}=${toInline value}\n")
          obj);

    toInline = obj:
      # Exclude drvs here, or we'll easily get infinite recursion.
      if isAttrs obj && !isStringLike obj then
        "{${concatStringsSep ","
          (mapAttrsToList
            (name: value: "${toJSON name}=${toInline value}")
            obj)
        }}"
      else if isList obj then
        "[${concatMapStringsSep "," toInline obj}]"
      else if obj == null then
        throw "“null” is not supported by TOML"
      else if !isFloat obj then
        # Strings, integers and booleans.
        toJSON obj
      # Sanitize +-inf and NaN. They'll produce "null", which is invalid for TOML.
      else if obj == inf then
        "inf"
      else if obj == -inf then
        "-inf"
      else if obj != obj then
        "nan"
      else
        toJSON obj;

  in
    toTopLevel;
}
