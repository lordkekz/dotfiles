# A very sketchy hack to show the list of homeConfigurations in nix flake show.
# Basically, we merge the homeConfigurations with a dummy package whose name lists enumerates the usernames.
{
  pkgs,
  system,
  homeConfigs,
}: {
  homeConfigurations =
    (derivation {
      name = "got users: ${(import ./listOfHomeConfigs.nix {inherit pkgs homeConfigs;}).listNamesNuon}";
      builder = "fake";
      inherit system;
    })
    // homeConfigs;
}
