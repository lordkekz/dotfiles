# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
{
  pkgs,
  system,
  ...
}: let
  sather-k-compiler-halle = import ./satk.nix {inherit pkgs system;};
in rec {
  # example = pkgs.callPackage ./example { };
  satk-base = sather-k-compiler-halle.satk-base;
  satk-wrapper = sather-k-compiler-halle.satk-wrapper;
  satk-get-examples = sather-k-compiler-halle.satk-get-examples;
  satk = sather-k-compiler-halle.satk-full;
}
