{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  personal-data,
  ...
}: let
  vmName = "minecraft";
  vmId = "16";
  user = "minecraft";
  group = "minecraft";
  unitsAfterPersist = ["minecraft-server-survival2.service" "minecraft-server-public.service"];
  pathsToChown = ["/persist"];
  fsType = "btrfs";

  paperServer = pkgs.paper-server;
  minecraftVersion = lib.head (lib.match "/nix/store/[^/]*-minecraft-server-([^-/]+)/.*" paperServer.vanillaJar);
  serverConfig = name: mcport: webport: {
    enable = true;
    autoStart = true; # TODO this may be a default
    restart = "always"; # TODO this may be a default
    jvmOpts = "-Xmx3G";
    package = paperServer;
    serverProperties = {
      motd = "NixOS Minecraft Server: ${name}";
      server-port = mcport;
      max-players = 1000;
      white-list = true;
      gamemode = "survival";
      difficulty = "normal";
      simulation-distance = 10;
      view-distance = 32;
      pause-when-empty-seconds = 1;
    };
    whitelist."LordKekz" = "e98caca4-c4d6-42d2-88f0-d37dd965d365";
    symlinks = {
      # This avoids runtime downloads of server jar
      "cache/mojang_${minecraftVersion}.jar" = paperServer.vanillaJar;

      # Build CoreProtect from git to support latest minecraft
      "plugins/coreprotect.jar" = pkgs.maven.buildMavenPackage {
        pname = "CoreProtect";
        version = "unstable-2024-12-10";

        src = pkgs.fetchFromGitHub {
          owner = "PlayPro";
          repo = "CoreProtect";
          rev = "b3db65d07d129e77f13b433e4d29729d4a971651";
          hash = "sha256-zHOKVXHMJ0WEpWdBWCYXzN4hGBhp9s2EaoLUWivMTlc=";
        };
        mvnHash = "sha256-CA4pUj2N2QIYeUkfbUJEEmFZA+EGNzX2ecfPm1aVpGI=";

        configurePhase = ''
          sed -i 's#<project.branch></project.branch>#<project.branch>development</project.branch>#' pom.xml
        '';

        installPhase = ''
          find | grep -iE "coreprotect.*jar"
          mv -v target/CoreProtect-22.4.jar "$out"
        '';
      };

      # Dependency for a lot of stuff
      "plugins/placeholder-api.jar" = pkgs.fetchurl {
        url = "https://hangarcdn.papermc.io/plugins/HelpChat/PlaceholderAPI/versions/2.11.6/PAPER/PlaceholderAPI-2.11.6.jar";
        hash = "sha256-v+oPI12p6dV2V3IVrLUMdLuBIuA9zZiDFbYRRce2Fyc=";
      };

      # Adds a proper /ping command
      "plugins/cleanping.jar" = pkgs.fetchurl {
        url = "https://github.com/frafol/CleanPing/releases/download/dev-build/CleanPing.jar";
        hash = "sha256-N8Fgy+dbamKfOkfTIDmRfRW0W790dPW/HaaKx5q6300=";
      };

      # Essentials plugin for stuff like /seen /ping and whatnot
      "plugins/essentialsx-core.jar" = pkgs.fetchurl {
        url = "https://github.com/EssentialsX/Essentials/releases/download/2.20.1/EssentialsX-2.20.1.jar";
        hash = "sha256-gC6jC9pGDKRZfoGJJYFpM8EjsI2BJqgU+sKNA6Yb9UI=";
      };

      # Allow newer and older clients to connect
      "plugins/viaversion.jar" = pkgs.fetchurl {
        url = "https://hangarcdn.papermc.io/plugins/ViaVersion/ViaVersion/versions/5.2.1/PAPER/ViaVersion-5.2.1.jar";
        hash = "sha256-yaWqtqxikpaiwdeyfANzu6fp3suSF8ePmJXs9dN4H8g=";
      };
      "plugins/viabackwards.jar" = pkgs.fetchurl {
        url = "https://hangarcdn.papermc.io/plugins/ViaVersion/ViaBackwards/versions/5.2.1/PAPER/ViaBackwards-5.2.1.jar";
        hash = "sha256-p7xmdGLXjzdTkdQgbOjBuf/V/jSEbP5TzE0bBSA9IXM=";
      };

      # BlueMap plugin generates a 3D browser map of minecraft worlds
      "plugins/bluemap.jar" = pkgs.fetchurl {
        url = "https://github.com/BlueMap-Minecraft/BlueMap/releases/download/v5.5/bluemap-5.5-paper.jar";
        hash = "sha256-nZxBbF1KkGHveZCKPJ0hHyJGXHnNSCKTvX5JRr0+s88=";
      };

      # Link BlueMap configs from this repo
      "plugins/BlueMap/maps" = ../assets/minecraft-bluemap-default-configs/maps;
      "plugins/BlueMap/storages" = ../assets/minecraft-bluemap-default-configs/storages;
      "plugins/BlueMap/core.conf" = ../assets/minecraft-bluemap-default-configs/core.conf;
      "plugins/BlueMap/webapp.conf" = ../assets/minecraft-bluemap-default-configs/webapp.conf;
      "plugins/BlueMap/webserver.conf" = pkgs.runCommand "minecraft-server-${name}-webserver.conf" {} ''
        sed 's#^port: .*$#port: ${builtins.toString webport}#' ${../assets/minecraft-bluemap-default-configs/webserver.conf} > $out
      '';
    };
    files = {
      # Set myself as an Operator
      "ops.json".value = [
        {
          name = "LordKekz";
          uuid = "e98caca4-c4d6-42d2-88f0-d37dd965d365";
          level = 4;
        }
      ];
    };
  };
in {
  services.caddy.virtualHosts."mcp.hepr.me".extraConfig = ''
    tls /var/lib/acme/hepr.me/cert.pem /var/lib/acme/hepr.me/key.pem
    reverse_proxy http://10.0.0.${vmId}:8002
  '';
  services.caddy.virtualHosts."mcs.hepr.me".extraConfig = ''
    tls /var/lib/acme/hepr.me/cert.pem /var/lib/acme/hepr.me/key.pem
    reverse_proxy http://10.0.0.${vmId}:8001
  '';

  networking.firewall.allowedTCPPorts = [25565 25566];
  networking.firewall.allowedUDPPorts = [25565 25566];
  networking.nftables.ruleset = ''
    table ip nat {
      chain PREROUTING {
        type nat hook prerouting priority dstnat; policy accept;
        tcp dport 25565 dnat to 10.0.0.${vmId}:25565
        udp dport 25565 dnat to 10.0.0.${vmId}:25565
        tcp dport 25566 dnat to 10.0.0.${vmId}:25566
        udp dport 25566 dnat to 10.0.0.${vmId}:25566
      }
    }
  '';

  microvm.vms.${vmName}.config = {config, ...}: {
    imports = [
      (import ./__microvmBaseConfig.nix {inherit personal-data vmName vmId user group unitsAfterPersist pathsToChown fsType;})
      inputs.nix-minecraft.nixosModules.minecraft-servers
    ];

    microvm.vcpu = lib.mkForce 10;
    microvm.balloonMem = lib.mkForce 7680; # MiB => total max of 8GiB memory

    networking.firewall.interfaces = {
      "vm-${vmName}-a" = {
        allowedTCPPorts = [8001 8002 25565 25566];
        allowedUDPPorts = [25565 25566];
      };
      "vm-${vmName}-b".allowedTCPPorts = [];
    };

    services.minecraft-servers = {
      enable = true;
      eula = true;
      openFirewall = true;
      dataDir = "/persist";
      servers.survival2 = lib.recursiveUpdate (serverConfig "survival2" 25565 8001) {
        whitelist."UrsulaUnke" = "b5bee075-5a0d-4c63-9c8f-9c5c230f0da3";
      };
      servers.public = lib.recursiveUpdate (serverConfig "public" 25566 8002) {
        whitelist = {
          "Leron44" = "26d8bea8-3661-4332-85b8-9a0cc1f6ac23";
          "Spyridon99" = "dfbaaa76-5889-4537-ae54-747d29689c16";
          "MerklingenRitter" = "8dbccbec-4cc5-44e6-af7c-760fef8168e3";
          "Nalsai" = "2bb1bfd9-7872-44ee-8865-e950a59f5bcc";
        };
        symlinks = {
          "plugins/iridium-skyblock.jar" = ../assets/IridiumSkyblock-4.1.0-B5.2.jar;
          "plugins/IridiumSkyblock/missions.yml" = ../assets/minecraft-iridium-configs/missions.yml;

          "plugins/fastasyncworldedit.jar" = pkgs.fetchurl {
            url = "https://github.com/IntellectualSites/FastAsyncWorldEdit/releases/download/2.12.3/FastAsyncWorldEdit-Paper-2.12.3.jar";
            hash = "sha256-b0xybeKRNUzDHyDxI5ONDYIqIT7KuDUASh7tQzPWCUc=";
          };

          "plugins/multiverse-core.jar" = pkgs.fetchurl {
            url = "https://hangarcdn.papermc.io/plugins/Multiverse/Multiverse-Core/versions/4.3.14/PAPER/multiverse-core-4.3.14.jar";
            hash = "sha256-J2MOl8aGEvLM0a9ykFVSjiKIeSPM5vbOzDTkVYPlrhE=";
          };
          "plugins/multiverse-inventories.jar" = pkgs.fetchurl {
            url = "https://hangarcdn.papermc.io/plugins/Multiverse/Multiverse-Inventories/versions/4.2.6/PAPER/multiverse-inventories-4.2.6.jar";
            hash = "sha256-Lh73k4g9iRFpDMtfi5OJMG9blauRXwZ4df8zt87Ep+g=";
          };

          # Drop-in replacement for Vault API
          # https://github.com/TheNextLvl-net/service-io
          # Alternative: https://hangar.papermc.io/TNE/VaultUnlocked or https://github.com/TheNewEconomy/VaultUnlockedAPI
          "plugins/service-io.jar" = pkgs.fetchurl {
            url = "https://hangarcdn.papermc.io/plugins/TheNextLvl/ServiceIO/versions/2.2.0/PAPER/service-io-2.2.0-all.jar";
            hash = "sha256-9a5XYm90ZQhpnyjHelQ9AaiNPlgmJDe0AQxJaue9dW0=";
          };
        };
      };
    };
  };
}
