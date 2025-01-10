# My Helix editor configuration
args @ {
  inputs,
  outputs,
  personal-data,
  pkgs,
  pkgs-stable,
  pkgs-unstable,
  system,
  lib,
  config,
  ...
}: {
  programs.helix = {
    enable = true;
    package = pkgs-unstable.helix;
    extraPackages = with pkgs-unstable; [
      bash-language-server
      jdt-language-server
      yaml-language-server
      vscode-langservers-extracted # contains LSPs for HTML,CSS,JSON
      marksman # Markdown LSP
    ];
    ignores = [];
    languages = {};
    settings.editor = {
      scrolloff = 3;
      line-number = "relative";
      rulers = [80 120];
      bufferline = "multiple";
      color-modes = true;
      # statusline = ...;
      lsp.display-inlay-hints = true;
      cursor-shape = {
        normal = "block";
        insert = "bar";
        select = "block";
      };
      indent-guides = {
        render = true;
        character = "▏"; # U+258F "Left One Eigth Block"
        skip-levels = 0;
      };
      inline-diagnostics = {
        cursor-line = "hint";
        other-lines = "error";
      };
    };
    settings.theme = "stylix-customized";
    themes.stylix-customized = {
      # Get the default values from the stylix config
      inherits = "stylix";

      # This applies to non-string keys in Nix
      "variable.other.member" = {
        fg = "base0C";
      };

      # This will become the cursor of the selections
      "ui.cursor" = {
        fg = "base00";
        bg = "base09"; # usually it is base0A, but that will be the primary now
      };
      # This is the color of the primary cursor, i.e., the one you always see
      "ui.cursor.primary" = {
        fg = "base00";
        bg = "base0E";
      };

      # This one is a bonus: the matching element (like a bracket) will be underlined
      # I somehow lose track which cursor is mine and which is just a highlight...
      "ui.cursor.match" = {
        fg = "base0A";
        modifiers = ["underlined"];
      };

      # This will become the color of the selections
      "ui.selection" = {
        fg = "base05";
        bg = "base03";
      };
      # This is the color of the primary/inline selection where the primary cursor is now
      "ui.selection.primary" = {
        fg = "base00";
        bg = "base04";
      };

      # Make line length rulers darker
      "ui.virtual.ruler" = {
        fg = "#141414";
      };

      # Make comments much more muted instead of sticking out
      "comment" = {
        fg = "base03";
      };
    };
  };
}
