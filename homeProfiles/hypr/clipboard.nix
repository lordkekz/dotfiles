# Clipboard management services
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
}: let
in {
  services.cliphist = {
    enable = true;
    #allowImages = true;
    #extraOptions = ...;
  };

  systemd.user.services.wl-clip-persist = {
    Unit = {
      Description = "Clipboard persistence daemon";
      PartOf = ["graphical-session.target"];
    };

    Service = {
      Type = "simple";
      ExecStart = "${lib.getExe pkgs.wl-clip-persist} --clipboard regular --all-mime-type-regex '(?i)^(?!image/x-inkscape-svg).+'";
      Restart = "on-failure";
    };

    Install = {WantedBy = ["graphical-session.target"];};
  };
}
