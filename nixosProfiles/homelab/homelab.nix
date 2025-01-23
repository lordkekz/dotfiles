# Basic user account config.
{
  inputs,
  outputs,
  nixosProfiles,
  personal-data,
  lib,
  config,
  pkgs,
  pkgs-stable,
  pkgs-unstable,
  ...
}: let
  inherit (personal-data.data.lab) username fullName hashedPassword publicKeys;
in {
  imports = [nixosProfiles.common];

  users.mutableUsers = false;
  users.users.${username} = {
    isNormalUser = true;
    description = fullName;
    inherit hashedPassword;
    openssh.authorizedKeys.keys = publicKeys;
    extraGroups = ["wheel" "systemd-journal"];
  };

  networking.nftables.enable = true;

  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "no";
    # require public key authentication for better security
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
  };

  # Mobile Shell: authenticate via ssh,
  # but then switch to using UDP ports 60000-61000.
  # mosh keeps connected when going to sleep or changing networks.
  # This sets up the server side (only on the servers) but the
  # OS's mosh package will be shadowed by the one from home-manager
  programs.mosh.enable = true;
}
