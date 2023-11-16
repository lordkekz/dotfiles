# USED_BY: /flake.nix
# DESC: Defines the homeConfigurations.
# CMD: 'home-manager --flake .#<username>'
{
  home-manager,
  nixpkgs,
  pkgs,
  inputs,
  outputs,
  ...
}: let
  myMkHomeConfig = username:
    home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      extraSpecialArgs = {inherit inputs outputs username;};
      modules = [./${username}];
    };
in rec {
  imports = [];

  hpreiser = myMkHomeConfig "hpreiser";
}
