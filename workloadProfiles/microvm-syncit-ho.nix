{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  personal-data,
  ...
}: let
  vmName = "syncit-ho";
  vmId = "11";
  user = "syncthing";
  group = "syncthing";
  unitsAfterPersist = ["syncthing.service" "syncthing-init.service"];
  pathsToChown = ["/persist"];
in {
  services.caddy.virtualHosts."syncit.hepr.me".extraConfig = ''
    tls /var/lib/acme/hepr.me/cert.pem /var/lib/acme/hepr.me/key.pem
    reverse_proxy http://10.0.0.${vmId}:8384
  '';

  microvm.vms.${vmName}.config = {config, ...}: {
    imports = [(import ./__microvmBaseConfig.nix {inherit personal-data vmName vmId user group unitsAfterPersist pathsToChown;})];

    networking.firewall.interfaces = {
      "vm-${vmName}-a".allowedTCPPorts = [22 8384];
      "vm-${vmName}-b" = {
        allowedTCPPorts = [22000];
        allowedUDPPorts = [22000 21027];
      };
    };

    services.syncthing = let
      persistentFolder = "/persist";
      personalSettings = personal-data.data.home.syncthing.settings persistentFolder;
      overrideRescanIntervalForEachFolder.folders = lib.mapAttrs (_:_: {rescanIntervalS = 86400;}) personalSettings.folders;
    in {
      enable = true;
      inherit user group;

      dataDir = persistentFolder + "/.syncthing-folders"; # Default folder for new synced folders
      configDir = persistentFolder + "/.config/syncthing"; # Folder for Syncthing's settings and keys

      guiAddress = "10.0.0.${vmId}:8384";
      overrideDevices = true; # overrides any devices added or deleted through the WebUI
      overrideFolders = true; # overrides any folders added or deleted through the WebUI
      settings = lib.foldl lib.recursiveUpdate personalSettings [{folders."Handy Kamera".enable = true;} overrideRescanIntervalForEachFolder];
    };
  };
}
