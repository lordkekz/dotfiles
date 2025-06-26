# Base stylix stuff.
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

    image = "${inputs.self.outPath}/assets/wallpapers/italy.jpg";
    # image = config.lib.stylix.pixel "base00"; # Black background for OLED
    #base16Scheme = "${pkgs.base16-schemes}/share/themes/tomorrow-night.yaml";
    # base16Scheme = "${pkgs.base16-schemes}/share/themes/rose-pine.yaml";
    # base16Scheme = "${pkgs.base16-schemes}/share/themes/da-one-black.yaml";
    # base16Scheme = "${pkgs.base16-schemes}/share/themes/primer-light.yaml";
    base16Scheme = "${pkgs.base16-schemes}/share/themes/da-one-paper.yaml";

    polarity = "light";

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
