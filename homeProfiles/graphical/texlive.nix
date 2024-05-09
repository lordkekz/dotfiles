# LaTeX stuff
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
  programs.texlive = {
    enable = true;
    extraPackages = tpkgs: {inherit (tpkgs) scheme-full;};
  };
  home.file."texmf/tex/latex".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/git/r4c-meta/tex";

  # Legacy texmf in Syncthing
  #home.file.texmf.source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/Documents/texmf";
}
