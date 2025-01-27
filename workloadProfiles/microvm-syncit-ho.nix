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
  microvmSecretsDir = "/run/agenix-microvm-syncit-ho";

  # Syncthing config
  persistentFolder = "/persist";
  personalSettings = personal-data.data.home.syncthing.settings persistentFolder;
  overrideRescanIntervalForEachFolder.folders = lib.mapAttrs (_:_: {rescanIntervalS = 86400;}) personalSettings.folders;
in {
  services.caddy.virtualHosts."syncit.hepr.me".extraConfig = ''
    tls /var/lib/acme/hepr.me/cert.pem /var/lib/acme/hepr.me/key.pem
    reverse_proxy http://10.0.0.${vmId}:8384
  '';
  services.caddy.virtualHosts."music.hepr.me".extraConfig = ''
    tls /var/lib/acme/hepr.me/cert.pem /var/lib/acme/hepr.me/key.pem

    @allowed path /rest/* /api/* /share/*
    handle @allowed {
      reverse_proxy http://10.0.0.${vmId}:4533 {
        @error status 404
        handle_response @error {
          redir https://hepr.me/
        }
      }
    }

    handle {
      redir https://hepr.me/
    }
  '';
  services.caddy.virtualHosts."nd.hepr.me".extraConfig = ''
    tls /var/lib/acme/hepr.me/cert.pem /var/lib/acme/hepr.me/key.pem
    reverse_proxy http://10.0.0.${vmId}:4533
  '';
  services.caddy.virtualHosts."scrobble.hepr.me".extraConfig = ''
    tls /var/lib/acme/hepr.me/cert.pem /var/lib/acme/hepr.me/key.pem
    reverse_proxy http://10.0.0.${vmId}:42010
  '';

  microvm.vms.${vmName}.config = {config, ...}: {
    imports = [(import ./__microvmBaseConfig.nix {inherit personal-data vmName vmId;})];

    microvm.balloonMem = lib.mkForce 2048; # MiB, speeds up big folders

    networking.firewall.interfaces = {
      "vm-${vmName}-a".allowedTCPPorts = [22 8384 4533 42010];
      "vm-${vmName}-b" = {
        allowedTCPPorts = [22000];
        allowedUDPPorts = [22000 21027];
      };
    };

    chown-paths =
      [
        {
          path = "/persist/.config/syncthing";
          user = "syncthing";
          group = "syncthing";
        }
        {
          path = "/persist/.maloja";
          user = "maloja";
          group = "maloja";
        }
        {
          path = "/persist/.navidrome";
          user = "navidrome";
          group = "navidrome";
        }
        {
          path = "/persist/.syncthing-folders";
          user = "syncthing";
          group = "syncthing";
        }
        {
          path = microvmSecretsDir;
          user = "maloja";
          group = "maloja";
        }
      ]
      ++ lib.mapAttrsToList (n: v: {
        inherit (v) path;
        user = "syncthing";
        group =
          if n == "Musik"
          then "navidrome"
          else "syncthing";
      })
      personalSettings.folders;

    microvm.shares = [
      {
        mountPoint = microvmSecretsDir;
        source = microvmSecretsDir;
        tag = "microvm-syncit-ho-secret";
        securityModel = "mapped";
      }
    ];

    services.syncthing = {
      enable = true;

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

        ListenBrainz.Enabled = true;
        ListenBrainz.BaseURL = "https://scrobble.hepr.me/apis/listenbrainz/1/";

        # Enabling this would risk a RCE vulnerability
        # (It's also not needed with the NixOS module)
        EnableTranscodingConfig = false;

        ShareURL = "https://music.hepr.me";
        EnableSharing = true; # Experimentally allows to share links of songs
      };
    };
    systemd.services.navidrome.serviceConfig.BindReadOnlyPaths = [
      # "/etc/static/resolv.conf"
      "/run/systemd/resolve/stub-resolv.conf"
    ];

    virtualisation.oci-containers = {
      backend = "podman";
      containers.maloja-scrobble = {
        imageFile = pkgs.dockerTools.pullImage {
          imageName = "krateng/maloja";
          imageDigest = "sha256:034896ea414f903153933a3d555082d6bbaec40b4703d0baf6aaf9d1285c6144";
          sha256 = "0c83ixfaaw924ib0i81ijpvyb35z5q2mdyb0ra7abl67sahgamlq";
          finalImageName = "krateng/maloja";
          finalImageTag = "latest";
        };
        image = "krateng/maloja";
        ports = ["42010:42010"];
        volumes = ["/persist/.maloja:/mjldata"];
        environment = {
          "MALOJA_DATA_DIRECTORY" = "/mjldata";
          "MALOJA_NAME" = "Keks";
          "PUID" = "835";
          "PGID" = "835";
        };
        environmentFiles = ["${microvmSecretsDir}/maloja-password.env"];
      };
    };
    users.users.maloja = {
      isSystemUser = true;
      group = "maloja";
      uid = 835; # Just some UID
    };
    users.groups.maloja.gid = 835; # Just some GID
  };

  age.secrets.maloja-password = {
    rekeyFile = "${inputs.self.outPath}/secrets/maloja-password.age";
    path = "${microvmSecretsDir}/maloja-password.env";
    symlink = false; # Required since the vm can't see the target if it's a symlink
    mode = "600"; # Allow the VM's root to chown it for radicale user
    owner = "microvm";
    group = "kvm";
  };
}
