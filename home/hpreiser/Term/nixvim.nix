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

    options = {
      number = true; # Show line numbers
      relativenumber = true; # Show relative line numbers

      shiftwidth = 2; # Tab width should be 2
    };

    # LSP
    plugins.lsp.enable = true;
    plugins.lsp.servers = {
      nixd.enable = true;
      #nushell.enable = true; # Not yet available on nixos-23.11; mixing nixvim unstable and nixpkgs stable wreaks havoc.
      java-language-server.enable = true;
    };

    # Misc plugins
    plugins.which-key.enable = true;
    extraPlugins = with pkgs.vimPlugins; [
      vim-numbertoggle
    ];
  };
}
