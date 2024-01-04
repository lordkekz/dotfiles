# USED_BY: /flake.nix
# DESC: Defines the nixosConfigurations.
# CMD: 'nixos-rebuild switch --flake .#<hostname>'
{
  # Flake's inputs and outputs
  inputs,
  outputs,
}: let
  myMkNixOSConfig = hostname:
    inputs.nixpkgs.lib.nixosSystem {
      specialArgs = {inherit inputs outputs;};
      modules = [./${hostname}];
    };
in {
  kekswork2312 = myMkNixOSConfig "kekswork2312";
}
