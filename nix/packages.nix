{ lib, pkgs, ... }:

let
  names = import ./read-list.nix lib ./packages.txt;
  package =
    name:
    lib.attrByPath (lib.splitString "." name)
      (throw "nix/packages.txt: Nixpkgs has no package '${name}'.")
      pkgs;
in
{
  # The list is in nix/packages.txt. Add packages that need a Nix expression
  # here, for example: ++ [ (pkgs.python3.withPackages (ps: [ ps.requests ])) ].
  home.packages = map package names;
}
