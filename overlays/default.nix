# This file defines overlays
args @ {
  # Flake's inputs and outputs
  inputs,
  outputs,
}: {
  # This one brings our custom packages from the 'pkgs' directory
  #additions = final: _prev: ""; #forAllSystems (system: import ../pkgs {pkgs = final; inherit system;});

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://wiki.nixos.org/wiki/Overlays
  #modifications = final: prev: ""; #{
  # example = prev.example.overrideAttrs (oldAttrs: rec {
  # ...
  # });
  #  };

  # When applied, the unstable nixpkgs set (declared in the flake inputs) will
  # be accessible through 'pkgs.unstable'
  #unstable-packages = final: _prev: {
  #  unstable = import inputs.nixpkgs-unstable {
  #    system = final.system;
  #    config.allowUnfree = true;
  #  };
  #};
}
