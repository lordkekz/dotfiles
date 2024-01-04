# USED_BY: /flake.nix
# DESC: Defines the homeConfigurations.
# CMD: 'home-manager --flake .#<username> switch'
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
  myMkHomeConfig = username: mode:
    inputs.home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      extraSpecialArgs = {inherit inputs outputs username mode system;};
      modules = [./${username}];
    };
in {
  "hpreiser@Desk" = myMkHomeConfig "hpreiser" {
    desktop = true;
    terminal = true;
  };
  "hpreiser@Term" = myMkHomeConfig "hpreiser" {
    desktop = false;
    terminal = true;
  };
  hpreiser = throw "Just choose bro";
}
