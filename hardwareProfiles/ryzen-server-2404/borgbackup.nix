{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  # The Borg Backup module from nixpkgs creates the directory, creates a borg user and configures
  # the ssh keys for the user (but restricts it to run `borg serve` via ssh)
  # Note: It does *not* run its own ssh server, so the borg client needs to use the regular sshd too
  services.borgbackup.repos = {
    orion-backups-borg = {
      authorizedKeys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHj4uH1IUsz562ATVM+6GW/3dNC3y+KDTVK79bQn61+w root@vortex"
      ];
      path = "/orion/backups/borg";
    };
  };
}
