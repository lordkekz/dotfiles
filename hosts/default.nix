# USED_BY: /flake.nix
# DESC: Defines the nixosConfigurations.
# CMD: 'nixos-rebuild switch --flake .#<hostname>'
{
  # Flake's inputs and outputs
  inputs,
  outputs,
}: let
  myMkNixOSConfigParams = hostname: {
    specialArgs = {inherit inputs outputs;};
    modules = [./${hostname}];
  };
  nixosConfig = inputs.nixpkgs.lib.nixosSystem;
in rec {
  # Specify the NixOS config params for each of my configs.
  # This acts as a source of truth.
  nixosConfigurationParams = {
    kekswork2312 = myMkNixOSConfigParams "kekswork2312";
  };

  # Actually generate an attrset containing my NixOS configs.
  # This can be merged into legacyPackages.${system}
  nixosConfigurations = inputs.nixpkgs.lib.attrsets.mapAttrs (name: value: nixosConfig value) nixosConfigurationParams;

  # Generate an attrset containing only the root modules of each config.
  # This can be used to easily extends my config in other flakes, e.g. at work.
  nixosModules = inputs.nixpkgs.lib.attrsets.mapAttrs (name: value: builtins.elemAt value.modules 0) nixosConfigurationParams;
}
