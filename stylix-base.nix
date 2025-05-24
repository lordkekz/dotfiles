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
    enable = true;

    #image = stylix-image;
    image = config.lib.stylix.pixel "base00"; # Black background for OLED
    #base16Scheme = "${pkgs.base16-schemes}/share/themes/tomorrow-night.yaml";
    #base16Scheme = "${pkgs.base16-schemes}/share/themes/rose-pine.yaml";
    base16Scheme = "${pkgs.base16-schemes}/share/themes/da-one-black.yaml";

    polarity = "dark";

    fonts = {
      monospace = {
        name = "JetBrainsMono Nerd Font";
        package = pkgs.nerd-fonts.jetbrains-mono;
      };
      sansSerif = {
        name = "Arimo Nerd Font";
        package = pkgs.nerd-fonts.arimo;
      };
      serif = {
        name = "Tinos Nerd Font";
        package = pkgs.nerd-fonts.tinos;
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
      terminal = 0.9;
    };
  };
}
