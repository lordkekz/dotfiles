{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  personal-data,
  ...
}: let
  vmName = "radicale";
  vmId = "12";
  user = "radicale";
  group = "radicale";
  unitsAfterPersist = ["radicale.service"];
in {
  services.caddy.virtualHosts."caldav.hepr.me".extraConfig = ''
    tls /var/lib/acme/hepr.me/cert.pem /var/lib/acme/hepr.me/key.pem
    reverse_proxy http://10.0.0.12:5232
  '';

  microvm.vms.${vmName}.config = {config, ...}: {
    imports = [(import ./__microvmBaseConfig.nix {inherit vmName vmId user group unitsAfterPersist;})];

    networking.firewall.allowedTCPPorts = [5232];

    services.radicale = {
      enable = true;
      settings = {
        server.hosts = ["0.0.0.0:5232"];
        auth = {
          type = "htpasswd";
          htpasswd_filename = "${pkgs.writeText "radicale-users" personal-data.data.home.radicale.usersFile}";
          htpasswd_encryption = "autodetect";
        };
        storage = {
          filesystem_folder = "/persist";
          hook = lib.getExe (pkgs.writeShellApplication {
            name = "radicale-changes-hook-git";
            runtimeInputs = [pkgs.gitMinimal pkgs.coreutils];
            text = ''
              if [ ! -f .gitignore ]; then
                cat >.gitignore <<EOL
              .Radicale.cache
              .Radicale.lock
              .Radicale.tmp-*
              EOL
              fi

              # Make sure that there's a git repo
              git init

              # Configure git repo
              git config --local user.name "radicale"
              git config --local user.email "radicale@caldav.hepr.me"

              # Add & Commit changes
              git add -A
              STAGED_FILES=$(git diff --staged --name-only)
              STAGED_FILES_COUNT=$(echo "$STAGED_FILES" | wc -l)
              git diff --cached --quiet || git commit -m "Changes in $STAGED_FILES_COUNT files."
            '';
          });
        };
      };
    };
  };
}
