{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  services.borgbackup.repos = {
    orion-backups-borg = {
      authorizedKeys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHj4uH1IUsz562ATVM+6GW/3dNC3y+KDTVK79bQn61+w root@vortex"
      ];
      path = "/orion/backups/borg";
    };
  };
}
