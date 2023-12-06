# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
{
  pkgs,
  system,
  ...
}: rec {
  # example = pkgs.callPackage ./example { };
  satk = import ./satk.nix {inherit pkgs system;};
}
