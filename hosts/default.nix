# USED_BY: /flake.nix
# DESC: Defines the nixosConfigurations.
# CMD: 'nixos-rebuild switch --flake .#<hostname>'
{
  # Flake's inputs and outputs
  inputs,
  outputs,
}: let
  inherit (outputs.lib) subtractAttrSet;

  myMkNixOSConfigParams = hostname: {
    specialArgs = {inherit inputs outputs;};
    modules =
      [./${hostname}]
      # The nixosModules from below get merged into the output, so we need to filter them out.
      ++ (subtractAttrSet result.nixosConfigurationParams outputs.nixosModules);
  };
  nixosConfig = inputs.nixpkgs.lib.nixosSystem;

  result = rec {
    # Specify the NixOS config params for each of my configs.
    # This acts as a source of truth.
    nixosConfigurationParams = {
      kekswork2312 = myMkNixOSConfigParams "kekswork2312";
      nixos-wsl2 = myMkNixOSConfigParams "nixos-wsl2";
      nixos-live-image = myMkNixOSConfigParams "nixos-live-image";
    };

    # Actually generate an attrset containing my NixOS configs.
    # This can be merged into legacyPackages.${system}
    nixosConfigurations = inputs.nixpkgs.lib.attrsets.mapAttrs (name: value: nixosConfig value) nixosConfigurationParams;

    # Generate an attrset containing only the root modules of each config.
    # This can be used to easily extends my config in other flakes, e.g. at work.
    nixosModules = inputs.nixpkgs.lib.attrsets.mapAttrs (name: value: builtins.elemAt value.modules 0) nixosConfigurationParams;
  };
in
  result
