# USED_BY: /flake.nix
# DESC: Defines the homeConfigurations.
# CMD: 'home-manager --flake .#<username> switch'
{
  home-manager,
  nixpkgs,
  pkgs,
  inputs,
  outputs,
  ...
}: let
  myMkHomeConfig = username: mode:
    home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      extraSpecialArgs = {inherit inputs outputs username mode;};
      modules = [./${username}];
    };
in rec {
  imports = [];

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
