{
  inputs,
  outputs,
  nixosProfiles,
  lib,
  config,
  pkgs,
  pkgs-stable,
  pkgs-unstable,
  ...
}: {
  boot.plymouth = {
    enable = true;
    theme = "bgrt";
    themePackages = [
      # By default we would install all themes
      (pkgs.adi1090x-plymouth-themes.override {
        selected_themes = [
          "abstract_ring_alt"
          "colorful_sliced"
          "dark_planet"
          "deus_ex"
          "green_blocks"
          "hexagon"
          "red_loader"
        ];
      })
      pkgs.nixos-bgrt-plymouth # Theme name: "nixos-bgrt"
      pkgs.breeze-plymouth # Theme name: "breeze"
    ];
    #logo = ...;
  };
}
