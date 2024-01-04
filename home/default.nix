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
      extraSpecialArgs = {inherit inputs outputs system username;};
      modules = [./${username}/${mode}];
    };
in {
  "hpreiser@Desk" = myMkHomeConfig "hpreiser" "Desk";
  "hpreiser@Term" = myMkHomeConfig "hpreiser" "Term";
  hpreiser = throw "Just choose bro";
}
