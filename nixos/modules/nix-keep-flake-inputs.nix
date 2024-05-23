{ inputs, ... }:
{
  system.extraDependencies = let
    collectFlakeInputs =
      input: [ input ] ++ builtins.concatMap collectFlakeInputs (builtins.attrValues (input.inputs or {}));
  in
    builtins.concatMap collectFlakeInputs (builtins.attrValues inputs);
}
