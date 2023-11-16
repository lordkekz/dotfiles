# USED_BY: /flake.nix
# DESC: Defines the nixosConfigurations.
# CMD: 'nixos-rebuild --flake .#<hostname>'
{
  nixpkgs,
  pkgs,
  inputs,
  outputs,
  ...
}: let
  myMkNixOSConfig = hostname:
    nixpkgs.lib.nixosSystem {
      specialArgs = {inherit inputs outputs;};
      modules = [./hosts/${hostname}];
    };
in rec {
  imports = [];

  KeksWork-Win11 = myMkNixOSConfig KeksWork-Win11;
}
