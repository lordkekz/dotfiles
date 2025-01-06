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
  internalIP = "10.0.0.13";
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
    reverse_proxy http://${internalIP}:8000
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

    microvm.mem = lib.mkForce 3584; # MiB

    networking.firewall.interfaces = {
      "vm-${vmName}-a".allowedTCPPorts = [25565];
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
        symlinks."cache/mojang_${minecraftVersion}.jar" = paperServer.vanillaJar;
        serverProperties = {
          motd = "Minecraft Survival 2";
          server-port = 25565;
          max-players = 2;
          white-list = true;
          gamemode = "survival";
          difficulty = "normal";
        };
        whitelist = {
          "LordKekz" = "e98caca4-c4d6-42d2-88f0-d37dd965d365";
          "UrsulaUnke" = "b5bee075-5a0d-4c63-9c8f-9c5c230f0da3";
        };
      };
    };
  };
}
