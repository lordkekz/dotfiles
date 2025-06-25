{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  personal-data,
  system,
  ...
}: let
  vmName = "syncit-ho";
  vmId = "11";
  microvmSecretsDir = "/run/agenix-microvm-syncit-ho";

  # Syncthing config
  persistentFolder = "/persist";
  personalSettings = personal-data.data.home.syncthing.settings persistentFolder;
  overrideRescanIntervalForEachFolder.folders = lib.mapAttrs (_: _: {rescanIntervalS = 86400;}) personalSettings.folders;
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
    request_body {
      max_size 10MB
    }
    reverse_proxy http://10.0.0.${vmId}:42010
  '';
  services.caddy.virtualHosts."signal-backup.hepr.me".extraConfig = ''
    tls /var/lib/acme/hepr.me/cert.pem /var/lib/acme/hepr.me/key.pem
    handle {
      basic_auth {
        ${with personal-data.data.lab.signal-backups; "${user} ${pw}"}
      }
      reverse_proxy http://10.0.0.${vmId}:42020 {
        header_up Host {upstream_hostport}
        header_up X-Forwarded-User {http.auth.user.id}
      }
    }
  '';
  services.caddy.virtualHosts."vtt.hepr.me".extraConfig = ''
    tls /var/lib/acme/hepr.me/cert.pem /var/lib/acme/hepr.me/key.pem
    reverse_proxy http://10.0.0.${vmId}:30000
  '';

  microvm.vms.${vmName}.config = {config, ...}: {
    imports = [(import ./__microvmBaseConfig.nix {inherit personal-data vmName vmId;})];

    microvm.mem = lib.mkForce 4096; # MiB, speeds up big folders

    networking.firewall.interfaces = {
      "vm-${vmName}-a".allowedTCPPorts = [22 8384 4533 30000 42010 42020];
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
          path = "/persist/.navidrome";
          user = "navidrome";
          group = "navidrome";
        }
        {
          path = "/persist/.maloja";
          user = "maloja";
          group = "maloja";
        }
        {
          path = "/persist/.signalbackup-html";
          user = "signalbackup";
          group = "caddy";
        }
        {
          path = "/persist/.syncthing-folders";
          user = "syncthing";
          group = "syncthing";
        }
        {
          path = "/persist/.foundry";
          user = "foundryvtt";
          group = "foundryvtt";
        }
        {
          path = microvmSecretsDir + "/maloja";
          user = "maloja";
          group = "maloja";
        }
        {
          path = microvmSecretsDir + "/signalbackup";
          user = "signalbackup";
          group = "signalbackup";
        }
        {
          path = microvmSecretsDir + "/syncthing";
          user = "syncthing";
          group = "syncthing";
        }
      ]
      ++ lib.mapAttrsToList (n: v: {
        inherit (v) path;
        user = "syncthing";
        group =
          if n == "Musik"
          then "navidrome"
          else if n == "FoundryVTT"
          then "foundryvtt"
          else if n == "Backups Signal" || n == "Documents"
          then "signalbackup"
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

    ######################### SYNCTHING #########################
    services.syncthing = {
      enable = true;

      dataDir = persistentFolder + "/.syncthing-folders"; # Default folder for new synced folders
      configDir = persistentFolder + "/.config/syncthing"; # Folder for Syncthing's settings and keys

      guiAddress = "10.0.0.${vmId}:8384";
      overrideDevices = true; # overrides any devices added or deleted through the WebUI
      overrideFolders = true; # overrides any folders added or deleted through the WebUI
      apiKeyFile = "${microvmSecretsDir}/syncthing/apiKey";
      settings = lib.foldl lib.recursiveUpdate personalSettings [
        {
          folders."Handy Kamera".enable = true;
          folders."Backups Signal".enable = true;
        }
        overrideRescanIntervalForEachFolder
      ];
    };

    # See: https://docs.syncthing.net/users/faq.html#inotify-limits
    boot.kernel.sysctl."fs.inotify.max_user_watches" = 204800;

    ######################### NAVIDROME #########################
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

    #########################  MALOJA  ##########################
    virtualisation.oci-containers = {
      backend = "podman";
      containers.maloja-scrobble = {
        imageFile = pkgs.dockerTools.pullImage {
          imageName = "krateng/maloja";
          imageDigest = "sha256:4ecea26058d2ca5168a8d53820279942d28f0606664cea6425f42371d5d88f95";
          sha256 = "1yi8wnpv80bqqfpy1m3gbh2r4nzwc33fyj8gfm85a639jyrgdzx2";
          finalImageName = "krateng/maloja";
          finalImageTag = "latest";
        };
        image = "krateng/maloja";
        ports = ["42010:42010"];
        volumes = let
          maloja-config = {
            name = "Keks";
            # Use album info from latest scrobble
            # Options: first, last, majority
            # Default: first
            album_information_trust = "last";
            # FIXME update after https://github.com/krateng/maloja/issues/401
            invalid_artists = []; #["[Unknown Artist]" "Unknown Artist" "Spotify" "Unbekannter Künstler"];
            remove_from_title = ["(Original Mix)" "(Radio Edit)" "(Album Version)" "(Explicit Version)" "(Bonus Track)" "(Live)"];
            # Default only has first three
            delimiters_informal = ["vs." "vs" "&" "and" "with" "und" "mit"];
            # Default is missing the simple comma
            delimiters_formal = ["," ";" "/" "|" "␝" "␞" "␟"];
            parse_remix_artists = true;
            show_play_number_on_tiles = true;
            week_offset = 1; # Start on Monday
            timezone = 1; # UTC+1 Berlin
          };
          maloja-config-file = pkgs.writeText "maloja-settings.yml" (lib.generators.toYAML {} maloja-config);

          maloja-rules = lib.concatMapStringsSep "\n" (lib.concatStringsSep "\t") [
            ["replaceartist" "Galactikraken" "Jonathan Young"]
            ["replaceartist" "Torre Florim" "De Staat"]
            ["replaceartist" "LISA" "Lalisa"]
            ["replaceartist" "Lisa" "Lalisa"]
            ["countas" "Lalisa" "BLACKPINK"]
            ["replaceartist" "ROSE" "Rosé"]
            ["replaceartist" "ROSÉ" "Rosé"]
            ["countas" "Rosé" "BLACKPINK"]
            ["replaceartist" "JENNIE" "Jennie"]
            ["countas" "Jennie" "BLACKPINK"]
            ["replaceartist" "JISOO" "Jisoo"]
            ["countas" "Jisoo" "BLACKPINK"]
            ["belongtogether" "Abor & Tynna"]
          ];
          maloja-rules-file = pkgs.writeText "maloja-rules.tsv" maloja-rules;
        in [
          "/persist/.maloja:/mjldata"
          # Maloja uses a INI-like config by default:
          # - Python's ConfigParser is used for getting a dict
          # - Python's AST package is used for converting the strings to values
          # e.g. the following line would parse but I'm not willing to use it:
          # invalid_artists = ["first", "second"]
          # Instead, I'm making a yaml which is for some reason allowed but only
          # in the alternate location for secrets...
          "${maloja-config-file}:/run/secrets/maloja.yml"
          "${maloja-rules-file}:/mjldata/rules/keks.tsv"
        ];
        environment = {
          "MALOJA_DATA_DIRECTORY" = "/mjldata";
          "PUID" = "835";
          "PGID" = "835";
        };
        environmentFiles = ["${microvmSecretsDir}/maloja/password.env"];
      };
    };
    users.users.maloja = {
      isSystemUser = true;
      group = "maloja";
      uid = 835; # Just some UID
    };
    users.groups.maloja.gid = 835; # Just some GID

    ######################### SIGNALBACKUP ##########################
    services.caddy = {
      enable = true;
      virtualHosts.":42020".extraConfig = ''
        handle {
          root * /persist/.signalbackup-html
          file_server
        }
      '';
    };
    systemd.services.caddy.serviceConfig.ReadWritePaths = ["/persist/.signalbackup-html"];
    systemd.services.signal-backup-automation = {
      enableStrictShellChecks = true;
      path = [outputs.packages.${system}.signal-backup-automation];
      script = ''
        signal-backup-automation \
          "/persist/.signal-backups" \
          "/persist/Documents/Backup/Signal/" \
          "/persist/.signalbackup-html" \
          "${microvmSecretsDir}/signalbackup/passphrase"
      '';
      startAt = "minutely";
      serviceConfig.User = "signalbackup";
    };
    users.users.signalbackup = {
      isSystemUser = true;
      group = "signalbackup";
      uid = 836; # Just some UID
    };
    users.groups.signalbackup.gid = 836; # Just some GID

    ######################### FOUNDRYVTT ##########################
    systemd.services.foundryvtt = {
      enableStrictShellChecks = true;
      path = [pkgs.nodejs_20 pkgs.util-linux];
      script = let
        foundryOptionsJSON = pkgs.writers.writeJSON "FoundryVTT-options.json" {
          "port" = 30000;
          "hostname" = "vtt.hepr.me";
          "proxyPort" = 443;
          "proxySSL" = true;
          "dataPath" = "/persist/.foundry";
          "compressStatic" = true;
          "fullscreen" = false;
          "language" = "en.core";
          "localHostname" = null;
          "routePrefix" = null;
          "updateChannel" = "stable";
          "upnp" = false;
          "awsConfig" = null;
          "compressSocket" = true;
          "cssTheme" = "dark";
          "deleteNEDB" = false;
          "hotReload" = false;
          "passwordSalt" = null;
          "sslCert" = null;
          "sslKey" = null;
          "world" = null;
          "serviceConfig" = null;
          "telemetry" = false;
        };
      in ''
        echo "[FOUNDRYVTT SCRIPT] Linking options"
        mkdir -p '/persist/.foundry/Config'
        cp -f ${lib.escapeShellArg foundryOptionsJSON} '/persist/.foundry/Config/options.json'

        echo "[FOUNDRYVTT SCRIPT] Linking synced data"
        mkdir -p '/persist/.foundry/Data'
        mkdir -p '/persist/FoundryVTT/Data/keks'
        ln -sf -T '/persist/FoundryVTT/Data/keks' '/persist/.foundry/Data/keks'

        cd '/persist/FoundryVTT/Node'
        node main.js --port=30000 --dataPath=/persist/.foundry
      '';
      serviceConfig.User = "foundryvtt";
      wantedBy = ["multi-user.target"];
    };
    users.users.foundryvtt = {
      isSystemUser = true;
      group = "foundryvtt";
      uid = 837; # Just some UID
    };
    users.groups.foundryvtt.gid = 837; # Just some GID
  };

  age.secrets.maloja-password = {
    rekeyFile = "${inputs.self.outPath}/secrets/maloja-password.age";
    path = "${microvmSecretsDir}/maloja/password.env";
    symlink = false; # Required since the vm can't see the target if it's a symlink
    mode = "600"; # Allow the VM's root to chown it for radicale user
    owner = "microvm";
    group = "kvm";
  };
  age.secrets.signalbackup-passphrase = {
    rekeyFile = "${inputs.self.outPath}/secrets/signalbackup-passphrase.age";
    path = "${microvmSecretsDir}/signalbackup/passphrase";
    symlink = false; # Required since the vm can't see the target if it's a symlink
    mode = "600"; # Allow the VM's root to chown it for radicale user
    owner = "microvm";
    group = "kvm";
  };
  age.secrets.syncthing-api-key-nasman = {
    rekeyFile = "${inputs.self.outPath}/secrets/syncthing-api-key-nasman.age";
    path = "${microvmSecretsDir}/syncthing/apiKey";
    symlink = false; # Required since the vm can't see the target if it's a symlink
    mode = "600"; # Allow the VM's root to chown it for radicale user
    owner = "microvm";
    group = "kvm";
  };
}
