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
in {
  services.caddy.virtualHosts."caldav.hepr.me".extraConfig = ''
    tls /var/lib/acme/hepr.me/cert.pem /var/lib/acme/hepr.me/key.pem
    reverse_proxy http://10.0.0.12:5232
  '';

  systemd.services."microvm@${vmName}".preStart = "mkdir -p /persist/local/vm-${vmName}";
  microvm.vms.radicale.config = {config, ...}: {
    imports = [(import ./__microvmBaseConfig.nix {inherit vmName vmId;})];

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

    # Make sure the radicale user can access the persistent data
    # This is probably only needed on first boot to set the xargs due to 9p mount mode "mapped"
    # Better to chown them at each start of the VM so the files can be touched from the host without worry
    systemd.services.radicale.preStart = "+chown -R radicale:radicale /persist";
  };
}
