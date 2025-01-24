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
  pathsToChown = ["/persist" microvmSecretsDir];
  microvmSecretsDir = "/run/agenix-microvm-radicale";
in {
  services.caddy.virtualHosts."caldav.hepr.me".extraConfig = ''
    tls /var/lib/acme/hepr.me/cert.pem /var/lib/acme/hepr.me/key.pem
    reverse_proxy http://10.0.0.12:5232
  '';

  microvm.vms.${vmName}.config = {config, ...}: {
    imports = [(import ./__microvmBaseConfig.nix {inherit personal-data vmName vmId user group unitsAfterPersist pathsToChown;})];

    networking.firewall.interfaces = {
      "vm-${vmName}-a".allowedTCPPorts = [22 5232];
      "vm-${vmName}-b".allowedTCPPorts = [];
    };

    microvm.shares = [
      {
        mountPoint = microvmSecretsDir;
        source = microvmSecretsDir;
        tag = "microvm-radicale-secret";
        securityModel = "mapped";
      }
    ];

    services.radicale = {
      enable = true;
      settings = {
        server.hosts = ["10.0.0.${vmId}:5232"];
        auth = {
          type = "htpasswd";
          htpasswd_filename = "${pkgs.writeText "radicale-users" personal-data.data.home.radicale.usersFile}";
          htpasswd_encryption = "autodetect";
        };
        storage = {
          filesystem_folder = "/persist";
          # hook = ...;
        };
      };
    };

    systemd.services.radicale-git-push = let
      radicaleSettings = config.services.radicale.settings;
      radicaleUnit = config.systemd.services.radicale;
    in {
      requires = ["network.target"];
      serviceConfig = {
        inherit (radicaleUnit.serviceConfig) User Group ReadWritePaths;
      };
      enableStrictShellChecks = true;
      path = [pkgs.gitMinimal pkgs.coreutils];
      script = ''
        cd "${radicaleSettings.storage.filesystem_folder}" || exit 1

        # Make sure there's a .gitignore
        if [ ! -f .gitignore ]; then
          cat >.gitignore <<EOL
        .Radicale.cache
        .Radicale.lock
        .Radicale.tmp-*
        EOL
        fi

        # Make sure that there's a git repo
        git init --initial-branch "main"

        # Configure git repo
        git config --local user.name "radicale"
        git config --local user.email "radicale@caldav.hepr.me"

        # Add & Commit changes
        git add -A
        STAGED_FILES=$(git diff --staged --name-only)
        STAGED_FILES_COUNT=$(echo "$STAGED_FILES" | wc -l)
        git diff --cached --quiet || git commit -m "Changes in $STAGED_FILES_COUNT files. \

        $STAGED_FILES"

        # Push changes to forgejo
        git push "https://bot-radicale-push:$(cat ${microvmSecretsDir}/radicale-git-token)@git.hepr.me/the-family/Calendars.git" HEAD:main
      '';
      startAt = "minutely";
    };
  };

  age.secrets.radicale-git-token = {
    rekeyFile = "${inputs.self.outPath}/secrets/radicale-git-token.age";
    path = "${microvmSecretsDir}/radicale-git-token";
    symlink = false; # Required since the vm can't see the target if it's a symlink
    mode = "600"; # Allow the VM's root to chown it for radicale user
    owner = "microvm";
    group = "kvm";
  };
}
