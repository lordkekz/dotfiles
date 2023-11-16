# A very sketchy hack to show the list of homeConfigurations in nix flake show.
# Basically, we merge the homeConfigurations with a dummy package whose name lists enumerates the usernames.
{
  system,
  homeConfigs,
}: {
  homeConfigurations =
    (derivation {
      name = "got users: ${toString (builtins.filter (n: n != "imports") (builtins.attrNames homeConfigs))}";
      builder = "fake";
      inherit system;
    })
    // homeConfigs;
}
