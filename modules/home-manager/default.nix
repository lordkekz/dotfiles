# Add your reusable home-manager modules to this directory, on their own file (https://nixos.wiki/wiki/Module).
# These should be stuff you would like to share with others, not your personal configurations.
args @ {
  # Flake's inputs and outputs
  inputs,
  outputs,
}: {
  # List your module files here
  # my-module = import ./my-module.nix;
  firefox-desktopfile-per-profile = import ./firefox-desktopfile-per-profile.nix;
}
