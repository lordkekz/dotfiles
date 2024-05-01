# mpv video player.
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
  programs.mpv = {
    enable = true;
    # Overriden to add support for sixel graphics in terminal
    package =
      pkgs.wrapMpv
      (pkgs.mpv-unwrapped.override {sixelSupport = true;})
      {youtubeSupport = true;};
  };
}
