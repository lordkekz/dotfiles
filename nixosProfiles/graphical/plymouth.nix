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
    #theme = "nixos-bgrt";
    theme = "colorful_sliced";
    themePackages = [
      # By default we would install all themes
      (pkgs.adi1090x-plymouth-themes.override {
        selected_themes = [
          "abstract_ring_alt"
          "colorful_sliced"
          "deus_ex"
          "green_blocks"
          "hexagon"
          "red_loader"
        ];
      })
      pkgs.nixos-bgrt-plymouth # Theme name: "nixos-bgrt"
      pkgs.kdePackages.breeze-plymouth # Theme name: "breeze"
    ];
    #logo = ...;
  };
}
