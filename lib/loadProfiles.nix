{
  self,
  super,
  root,
  lib,
  flake,
}: let
  hl = flake.inputs.haumea.lib;

  # mkImportModulesForProfiles :: set of module -> set of (set of module) -> module
  mkImportModulesForProfiles = lib.mapAttrs (n: v: {...}: {
    imports = lib.attrValues v;
  });

  # loadModulesOfProfiles :: string -> set of (set of module)
  # e.g. (loadModulesOfProfiles "home").graphical.alacritty :: (home-manager module)
  loadModulesOfProfiles = profileKind:
    hl.load {
      src = "${flake.outPath}/dot2/${profileKind}Profiles";
      inputs = {};
      # Load it without passing inputs, to preserve the functional nature of the modules
      loader = hl.loaders.verbatim;
    };

  # loadProfiles :: string -> set of module -> set of module
  # e.g. (loadProfiles "home" []).graphical imports (loadModulesOfProfiles "home").graphical.*
  loadProfiles = profileKind:
    mkImportModulesForProfiles (loadModulesOfProfiles profileKind);
in {
  __functor = self: loadProfiles;
  inherit loadProfiles mkImportModulesForProfiles loadModulesOfProfiles;
}
