{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  personal-data,
  ...
}: let
  vmName = "syncit";
  vmId = "11";
in {
  services.caddy.virtualHosts."syncit.hepr.me".extraConfig = ''
    tls /var/lib/acme/hepr.me/cert.pem /var/lib/acme/hepr.me/key.pem
    reverse_proxy http://10.0.0.11:8384
  '';

  systemd.services."microvm@${vmName}".preStart = "+mkdir -p /persist/local/vm-${vmName}";
  microvm.vms.syncit.config = {config, ...}: {
    imports = [(import ./__microvmBaseConfig.nix {inherit vmName vmId;})];

    networking.firewall.allowedTCPPorts = [22000 8384];
    networking.firewall.allowedUDPPorts = [22000 21027];

    services.syncthing = let
      persistentFolder = "/persist";
      personalSettings = personal-data.data.home.syncthing.settings persistentFolder;
    in {
      enable = true;

      user = "syncthing";
      group = "syncthing";

      dataDir = persistentFolder + "/.syncthing-folders"; # Default folder for new synced folders
      configDir = persistentFolder + "/.config/syncthing"; # Folder for Syncthing's settings and keys

      guiAddress = "10.0.0.11:8384";
      overrideDevices = true; # overrides any devices added or deleted through the WebUI
      overrideFolders = true; # overrides any folders added or deleted through the WebUI
      settings = lib.recursiveUpdate personalSettings {
        folders."Handy Kamera".enable = true;
      };
    };

    # Make sure the syncthing user can access the config and synced directories
    # This is probably only needed on first boot to set the xargs due to 9p mount mode "mapped"
    # Better to chown them at each start of the VM so the files can be touched from the host without worry
    systemd.services.syncthing.preStart = "+chown -R syncthing:syncthing /persist";
    systemd.services.syncthing-init.preStart = "+chown -R syncthing:syncthing /persist";
  };
}
