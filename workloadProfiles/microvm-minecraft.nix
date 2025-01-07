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
  domain = "mc.hepr.me";
  user = "minecraft";
  group = "minecraft";
  unitsAfterPersist = ["minecraft-server-survival2.service"];
  pathsToChown = ["/persist"];
  fsType = "btrfs";

  paperServer = pkgs.paper-server;
  minecraftVersion = lib.head (lib.match "/nix/store/[^/]*-minecraft-server-([^-/]+)/.*" paperServer.vanillaJar);
in {
  services.caddy.virtualHosts.${domain}.extraConfig = ''
    tls /var/lib/acme/hepr.me/cert.pem /var/lib/acme/hepr.me/key.pem
    request_body {
      max_size 1GB
    }
    reverse_proxy http://10.0.0.${vmId}:8100
  '';

  networking.firewall.allowedTCPPorts = [25565];
  networking.nftables.ruleset = ''
    table ip nat {
      chain PREROUTING {
        type nat hook prerouting priority dstnat; policy accept;
        tcp dport 25565 dnat to 10.0.0.${vmId}:25565
      }
    }
  '';

  microvm.vms.${vmName}.config = {config, ...}: {
    imports = [
      (import ./__microvmBaseConfig.nix {inherit personal-data vmName vmId user group unitsAfterPersist pathsToChown fsType;})
      inputs.nix-minecraft.nixosModules.minecraft-servers
    ];

    microvm.vcpu = lib.mkForce 10;
    microvm.mem = lib.mkForce 6144; # MiB

    networking.firewall.interfaces = {
      "vm-${vmName}-a".allowedTCPPorts = [8100 25565];
      "vm-${vmName}-b".allowedTCPPorts = [];
    };

    services.minecraft-servers = {
      enable = true;
      eula = true;
      openFirewall = true;
      dataDir = "/persist";
      servers.survival2 = {
        enable = true;
        autoStart = true; # TODO this may be a default
        restart = "always"; # TODO this may be a default
        jvmOpts = "-Xmx3G";
        package = paperServer;
        serverProperties = {
          motd = "Minecraft Survival 2";
          server-port = 25565;
          max-players = 2;
          white-list = true;
          gamemode = "survival";
          difficulty = "normal";
          simulation-distance = 10;
          view-distance = 32;
          pause-when-empty-seconds = 1;
        };
        whitelist = {
          "LordKekz" = "e98caca4-c4d6-42d2-88f0-d37dd965d365";
          "UrsulaUnke" = "b5bee075-5a0d-4c63-9c8f-9c5c230f0da3";
        };
        symlinks = {
          # This avoids runtime downloads of server jar
          "cache/mojang_${minecraftVersion}.jar" = paperServer.vanillaJar;

          # BlueMap plugin generates a 3D browser map of minecraft worlds
          "plugins/bluemap.jar" = pkgs.fetchurl {
            url = "https://github.com/BlueMap-Minecraft/BlueMap/releases/download/v5.5/bluemap-5.5-paper.jar";
            hash = "sha256-nZxBbF1KkGHveZCKPJ0hHyJGXHnNSCKTvX5JRr0+s88=";
          };

          # Link BlueMap configs from this repo
          "plugins/BlueMap/maps" = "${inputs.self.outPath}/assets/minecraft-bluemap-default-configs/maps";
          "plugins/BlueMap/storages" = "${inputs.self.outPath}/assets/minecraft-bluemap-default-configs/storages";
          "plugins/BlueMap/core.conf" = "${inputs.self.outPath}/assets/minecraft-bluemap-default-configs/core.conf";
          "plugins/BlueMap/webapp.conf" = "${inputs.self.outPath}/assets/minecraft-bluemap-default-configs/webapp.conf";
          "plugins/BlueMap/webserver.conf" = "${inputs.self.outPath}/assets/minecraft-bluemap-default-configs/webserver.conf";
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
    };
  };
}
