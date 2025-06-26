# Extra stylix config for light mode
# Remember to import the nixos or home-manager modules for stylix!
{
  lib,
  pkgs,
  config,
  inputs,
  ...
}: {
  stylix = {
    enable = true;

    image = lib.mkForce "${inputs.self.outPath}/assets/wallpapers/italy.jpg";
    base16Scheme = lib.mkForce "${pkgs.base16-schemes}/share/themes/tomorrow.yaml";

    polarity = lib.mkForce "light";
  };
}
