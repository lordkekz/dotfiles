# My nixvim configuration.
args @ {
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  # extraSpecialArgs:
  system,
  username,
  pkgs-stable,
  pkgs-unstable,
  ...
}: {
  imports = [inputs.nixvim.homeManagerModules.nixvim];

  programs.nixvim = {
    enable = true;
    viAlias = true;
    plugins.lsp.enable = true;
    plugins.lsp.servers = {
      nixd.enable = true;
      #nushell.enable = true; # Not yet available on nixos-23.11; mixing nixvim unstable and nixpkgs stable wreaks havoc.
      java-language-server.enable = true;
    };
  };
}
