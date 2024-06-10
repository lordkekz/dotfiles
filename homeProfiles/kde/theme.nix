# My theming for KDE Plasma
# TODO Consolidate with Stylix, Hyprland, and figure out a dynamic ricing system.
args @ {
  inputs,
  outputs,
  homeProfiles,
  personal-data,
  pkgs,
  pkgs-stable,
  pkgs-unstable,
  system,
  lib,
  config,
  ...
}: {
  home.packages = [
    # Install theme package, so that its outputs will be in user share and plasma can find it.
    #pkgs.graphite-kde-theme
  ];

  # Style Apps using Qt
  # FIXME this breaks on Plasma 6, see https://github.com/nix-community/home-manager/issues/5098
  #qt = {
  #  enable = true;
  #  platformTheme = "kde";
  #  #style.name = "kvantum";
  #};

  # Tell kvantum which style to use
  #xdg.configFile."Kvantum/kvantum.kvconfig".text = ''
  #  [General]
  #  theme=GraphiteNordDark
  #'';
  #xdg.configFile."Kvantum/GraphiteNord".source = "${pkgs.graphite-kde-theme}/share/Kvantum/GraphiteNord";

  # Tell plasma which style to use
  #programs.plasma.workspace = {
  #  theme = "Graphite-nord-dark"; # Got the name using `plasma-apply-desktoptheme --list-themes`
  #  colorScheme = "GraphiteNordDark";
  #  cursorTheme = "Breeze_Snow";
  #  lookAndFeel = "com.github.vinceliuice.Graphite-nord-dark";
  #  #iconTheme = "Breeze Dark";
  #  wallpaper = "${pkgs.graphite-kde-theme}/share/wallpapers/Graphite-nord-dark/contents/images/3840x2160.png";
  #};
}
