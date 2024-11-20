{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  personal-data,
  ...
}: {
  microvm.vms.radicale.config = {config, ...}: {
    imports = [
      (import ./__microvmBaseConfig.nix {
        vmName = "radicale";
        vmId = "12";
      })
    ];

    microvm.shares = [
      {
        mountPoint = "/persist";
        source = "/persist/local/microvm-radicale";
        tag = "microvm-radicale-persist";
        securityModel = "mapped";
      }
    ];

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
          filesystem_folder = "/persist/radicale-collections";
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
