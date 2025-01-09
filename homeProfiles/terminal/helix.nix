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
      vscode-langservers-extracted # contains LSPs for HTML,CSS,JSON,ESLint,Markdown
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
    # Theming is done by stylix automatically
  };
}
