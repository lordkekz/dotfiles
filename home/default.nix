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
}:
with pkgs.lib.attrsets; let
  myMkHomeConfigParams = username: mode: {
    inherit pkgs;
    extraSpecialArgs = {inherit inputs outputs pkgs-stable pkgs-unstable system username;};
    modules =
      [./${username}/${mode}]
      # Unlike with hosts, we don't put homeModules from below into
      # homeManagerModules output, so no filtering required.
      ++ (attrValues outputs.homeManagerModules);
  };
  hmConfig = inputs.home-manager.lib.homeManagerConfiguration;
in rec {
  # Specify the home config params for each of my configs.
  # This acts as a source of truth.
  homeConfigurationParams = {
    "hpreiser@Desk" = myMkHomeConfigParams "hpreiser" "Desk";
    "hpreiser@Term" = myMkHomeConfigParams "hpreiser" "Term";
  };

  # Actually generate an attrset containing my home configs.
  # This can be merged into legacyPackages.${system}
  homeConfigurations = mapAttrs (name: value: hmConfig value) homeConfigurationParams;

  # Generate an attrset containing only the root modules of each config.
  # This can be used to easily extends my config in other flakes, e.g. at work.
  homeModules = mapAttrs (name: value: builtins.elemAt value.modules 0) homeConfigurationParams;
}
