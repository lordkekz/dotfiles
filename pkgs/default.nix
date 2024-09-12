# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
args @ {
  self,
  super,
  root,
  # Flake's inputs and outputs
  flake,
  inputs,
  outputs,
  assets,
  # Targeted system
  system,
  # Nixpkgs instances for targeted system
  pkgs,
  pkgs-stable,
  pkgs-unstable,
}: {
  hm = inputs.home-manager.packages.${system}.default;
  pm = inputs.plasma-manager.packages.${system}.default;
  kn = inputs.kubenix.packages.${system}.default.override {
    module = import ../kubernetes/cluster.nix;
    # optional; pass custom values to the kubenix module
    specialArgs = {flake = self;};
  };
}
