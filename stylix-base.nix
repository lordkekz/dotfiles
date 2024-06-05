# Base stylix stuff.
# Remember to import the nixos or home-manager modules for stylix!
{
  lib,
  pkgs,
  config,
  stylix-image,
  ...
}: {
  stylix = {
    image = stylix-image;
    #base16Scheme = "${pkgs.base16-schemes}/share/themes/tomorrow-night.yaml";
    base16Scheme = "${pkgs.base16-schemes}/share/themes/rose-pine.yaml";
    polarity = "dark";

    targets.gtk.enable = true;

    fonts = let
      nerdfonts = pkgs.nerdfonts.override {fonts = ["JetBrainsMono" "Arimo" "Tinos"];};
    in {
      monospace = {
        name = "JetBrainsMono Nerd Font";
        package = nerdfonts;
      };
      sansSerif = {
        name = "Arimo Nerd Font";
        package = nerdfonts;
      };
      serif = {
        name = "Tinos Nerd Font";
        package = nerdfonts;
      };
      sizes = {
        applications = 12;
        desktop = 10;
        popups = 10;
        terminal = 13;
      };
    };

    opacity = {
      applications = 1.0;
      desktop = 0.9;
      popups = 1.0;
      terminal = 0.95;
    };
  };
}
