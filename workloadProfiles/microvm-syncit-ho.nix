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
  services.caddy.virtualHosts."music.hepr.me".extraConfig = ''
    tls /var/lib/acme/hepr.me/cert.pem /var/lib/acme/hepr.me/key.pem
    reverse_proxy http://10.0.0.${vmId}:4533
  '';
  services.caddy.virtualHosts."nd.hepr.me".extraConfig = ''
    tls /var/lib/acme/hepr.me/cert.pem /var/lib/acme/hepr.me/key.pem
    reverse_proxy http://10.0.0.${vmId}:4533
  '';

  microvm.vms.${vmName}.config = {config, ...}: {
    imports = [(import ./__microvmBaseConfig.nix {inherit personal-data vmName vmId user group unitsAfterPersist pathsToChown;})];

    microvm.balloonMem = lib.mkForce 2048; # MiB, speeds up big folders

    networking.firewall.interfaces = {
      "vm-${vmName}-a".allowedTCPPorts = [22 8384 4533];
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

    services.navidrome = {
      enable = true;
      settings = {
        BaseUrl = "https://nd.hepr.me";
        Address = "10.0.0.${vmId}";
        Port = 4533;

        MusicFolder = "/persist/Music"; # The "Music" syncthing folder
        DataFolder = "/persist/.navidrome"; # Folder to store app data (DB)
        CacheFolder = "/tmp/navidrome-cache"; # Folder to store cache (transcoding etc.)
        EnableInsightsCollector = true; # Send anonymouse usage statistics

        # Enabling this would risk a RCE vulnerability
        # (It's also not needed with the NixOS module)
        EnableTranscodingConfig = false;

        ShareURL = "https://music.hepr.me";
        EnableSharing = true; # Experimentally allows to share links of songs
      };
    };
  };
}
