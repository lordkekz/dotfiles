{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  personal-data,
  ...
}: {
  microvm.vms.syncit.config = {config, ...}: {
    imports = [(import ./__microvmBaseConfig.nix {vmName = "syncit";})];

    systemd.network.networks."20-lan" = {
      matchConfig.Type = "ether";
      networkConfig = {
        Address = "10.0.0.11/24";
        Gateway = "10.0.0.1";
      };
    };

    microvm.shares = [
      {
        mountPoint = "/persist";
        source = "/persist/local/microvm-syncit";
        tag = "microvm-syncit-persist";
        securityModel = "mapped";
      }
    ];

    networking.firewall.allowedTCPPorts = [22000 8384];
    networking.firewall.allowedUDPPorts = [22000 21027];

    services.syncthing = let
      persistentFolder = "/persist";
      fullSettings = personal-data.data.home.syncthing.settings persistentFolder;
    in {
      enable = true;

      user = "root";
      group = "root";

      dataDir = persistentFolder + "/.syncthing-folders"; # Default folder for new synced folders
      configDir = persistentFolder + "/.config/syncthing"; # Folder for Syncthing's settings and keys

      guiAddress = "10.0.0.11:8384";
      overrideDevices = true; # overrides any devices added or deleted through the WebUI
      overrideFolders = true; # overrides any folders added or deleted through the WebUI
      settings.devices = fullSettings.devices;
      settings.folders = {
        inherit (fullSettings.folders) Documents;
      };
    };
  };
}
