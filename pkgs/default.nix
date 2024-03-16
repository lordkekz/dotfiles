# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
args @ {
  # Flake's inputs and outputs
  inputs,
  outputs,
  # Targeted system
  system,
  # Nixpkgs instances for targeted system
  pkgs-stable,
  pkgs-unstable,
  pkgs,
}: let
  sather-k-compiler-halle = import ./satk.nix args;
in rec {
  hm = inputs.home-manager.packages.${system}.default;
  pm = inputs.plasma-manager.packages.${system}.default;

  satk-base = sather-k-compiler-halle.satk-base;
  satk-wrapper = sather-k-compiler-halle.satk-wrapper;
  satk-get-examples = sather-k-compiler-halle.satk-get-examples;
  satk = sather-k-compiler-halle.satk-full;
}
