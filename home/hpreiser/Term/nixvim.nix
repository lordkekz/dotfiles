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
      expandtab = true; # Expad tabs to spaces
      shiftwidth = 2; # Tab width should be 2
    };

    # LSP
    plugins.lsp.enable = true;
    plugins.lsp.servers = {
      nixd.enable = true;
      #nushell.enable = true; # Not yet available on nixos-23.11; mixing nixvim unstable and nixpkgs stable wreaks havoc.
      java-language-server.enable = true;
    };

    plugins = {
      telescope = {
        enable = true;
        extensions = {
          file_browser.enable = true;
          frecency.enable = true;
        };
      };
      which-key.enable = true;
      # Guess tab size based on first tab-like occurence in file
      # Not available in 23.11
      #indent-o-matic.enable = true;
      # Colorize color codes like #abcdef or gray
      nvim-colorizer.enable = true;
      # Indentation guides
      indent-blankline = {
        enable = true;
        indent.char = "▏"; # U+258F "Left One Eigth Block" instead of quarter block
      };
      # Git Signs shows if lines are changed in working tree
      gitsigns = {
        enable = true;
        base = "HEAD"; # Compare to HEAD, not staged
        numhl = true; # Set line number bg
        linehl = false; # Don't set line bg
        signcolumn = false; # Don't show signs in column
        wordDiff = true; # Set bg of changed words
        currentLineBlame = true;
        currentLineBlameOpts.virtTextPos = "right_align";
      };
      # Highlight where the cursor jumps
      specs = {
        enable = true;
        min_jump = 5;
        increment = 10;
        color = "white";
        width = 10;
        fader = {
          builtin = null;
          custom = ''
            function(blend, cnt)
              if blend + math.floor(math.exp(cnt)) <= 100 then
                return 100 - blend - math.floor(math.exp(cnt))
              else return nil end
            end
          '';
        };
      };
    };

    extraPlugins = with pkgs.vimPlugins; [
      vim-numbertoggle
    ];

    colorschemes = {
      ayu.enable = true;
      ayu.extraOptions.mirage = true;
    };
  };
}
