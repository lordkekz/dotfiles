{pkgs, ...}:
pkgs.tmuxPlugins.mkTmuxPlugin {
  pluginName = "matryoshka";
  version = "unstable-2024-06-20";
  src = pkgs.fetchFromGitHub {
    owner = "niqodea";
    repo = "tmux-matryoshka";
    rev = "8ca859ea14d9edc9f93d537e19b2ec9694968881";
    hash = "sha256-r+wBd5JqRMUrssVjr5gIo8cNrSmIQP8vfK7e5e+21es=";
  };
  meta = {
    license = pkgs.lib.licenses.mit;
    description = "Plugin for nested tmux workflows";
  };
}
