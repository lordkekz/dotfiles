{pkgs, ...}:
pkgs.tmuxPlugins.mkTmuxPlugin {
  pluginName = "matryoshka";
  version = "unstable-2025-01-04";
  src = pkgs.fetchFromGitHub {
    owner = "niqodea";
    repo = "tmux-matryoshka";
    rev = "main";
    hash = "sha256-r1p8soVcG+GFvacubr3R7eHqzaUwSfbvgvWFeYXntZQ=";
  };
  meta = {
    license = pkgs.lib.licenses.mit;
    description = "Plugin for nested tmux workflows";
  };
}
