{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  personal-data,
  ...
}: let
  vmName = "forgejo";
  vmId = "17";
  user = "forgejo";
  group = "forgejo";
  unitsAfterPersist = ["forgejo-secrets.service" "forgejo.service"];
  pathsToChown = ["/persist" microvmSecretsDir];
  hostConfig = config;
  microvmSecretsDir = "/run/agenix-microvm-forgejo-runner";
in {
  microvm.vms.${vmName}.config = {config, ...}: {
    imports = [(import ./__microvmBaseConfig.nix {inherit personal-data vmName vmId user group unitsAfterPersist pathsToChown;})];

    networking.firewall.interfaces = {
      "vm-${vmName}-a".allowedTCPPorts = [];
      "vm-${vmName}-b".allowedTCPPorts = [];
    };

    # FIXME increase memory once it actually builds software and I get more RAM
    microvm.balloonMem = lib.mkForce 2048; # MiB

    microvm.shares = [
      {
        mountPoint = microvmSecretsDir;
        source = microvmSecretsDir;
        tag = "microvm-forgejo-runner-secret";
        securityModel = "mapped";
      }
    ];

    services.gitea-actions-runner = {
      package = pkgs.forgejo-actions-runner;
      instances.default = {
        enable = true;
        name = "microvm17";
        url = "https://git.hepr.me";
        tokenFile = hostConfig.age.secrets.forgejo-runner-registration-token.path;
        labels = [
          "ubuntu:docker://ubuntu:latest"
          "nix-flakes:docker://nixpkgs/nix-flakes:latest"
          # optionally provide native execution on the host:
          # "native:host"
        ];
        settings = {
          # The level of logging, can be trace, debug, info, warn, error, fatal
          log.level = "debug";

          runner = {
            # Where to store the registration result.
            # file = ".runner";

            # Execute how many tasks concurrently at the same time.
            capacity = 4;

            # Extra environment variables to run jobs.
            # envs = {};

            # Extra environment variables to run jobs from a file.
            # It will be ignored if it's empty or the file doesn't exist.
            # env_file = ".env";

            # The timeout for a job to be finished.
            # Please note that the Forgejo instance also has a timeout (3h by default) for the job.
            # So the job could be stopped by the Forgejo instance if it's timeout is shorter than this.
            timeout = "3h";

            # The timeout for the runner to wait for running jobs to finish when
            # shutting down because a TERM or INT signal has been received.  Any
            # running jobs that haven't finished after this timeout will be
            # cancelled.
            # If unset or zero the jobs will be cancelled immediately.
            shutdown_timeout = "20s";

            # Whether skip verifying the TLS certificate of the instance.
            insecure = false;

            # The timeout for fetching the job from the Forgejo instance.
            fetch_timeout = "5s";

            # The interval for fetching the job from the Forgejo instance.
            fetch_interval = "2s";

            # The interval for reporting the job status and logs to the Forgejo instance.
            report_interval = "1s";

            # The labels of a runner are used to determine which jobs the runner can run, and how to run them.
            # Like = ["macos-arm64:host", "ubuntu-latest:docker://node:20-bookworm", "ubuntu-22.04:docker://node:20-bookworm"]
            # If it's empty when registering, it will ask for inputting labels.
            # If it's empty when executing the `daemon`, it will use labels in the `.runner` file.
            # labels = [];
          };

          cache = {
            # Enable cache server to use actions/cache.
            enabled = true;

            # The directory to store the cache data.
            # If it's empty, the cache data will be stored in $HOME/.cache/actcache.
            # dir = "";

            # The host of the cache server.
            # It's not for the address to listen, but the address to connect from job containers.
            # So 0.0.0.0 is a bad choice, leave it empty to detect automatically.
            # host = "";

            # The port of the cache server.
            # 0 means to use a random available port.
            # port = 0;

            # The external cache server URL. Valid only when enable is true.
            # If it's specified, it will be used to set the ACTIONS_CACHE_URL environment variable. The URL should generally end with "/".
            # Otherwise it will be set to the the URL of the internal cache server.
            # external_server = "";
          };

          container = {
            # Specifies the network to which the container will connect.
            # Could be host, bridge or the name of a custom network.
            # If it's empty, create a network automatically.
            network = "";

            # Whether to create networks with IPv6 enabled. Requires the Docker daemon to be set up accordingly.
            # Only takes effect if "network" is set to "".
            enable_ipv6 = false;

            # Whether to use privileged mode or not when launching task containers (privileged mode is required for Docker-in-Docker).
            privileged = false;

            # Additional options to be used when the container is started (e.g., --add-host=my.forgejo.url:host-gateway).
            # options = "";

            # The parent directory of a job's working directory.
            # If it's empty, /workspace will be used.
            # workdir_parent = "";

            # Volumes (including bind mounts) can be mounted to containers. Glob syntax is supported, see https://github.com/gobwas/glob
            # You can specify multiple volumes. If the sequence is empty, no volumes can be mounted.
            # For example, if you only allow containers to mount the `data` volume and all the json files in `/src`, you should change the config to:
            # valid_volumes:
            #   - data
            #   - /src/*.json
            # If you want to allow any volume, please use the following configuration:
            # valid_volumes:
            #   - '**'
            # valid_volumes = []

            # overrides the docker client host with the specified one.
            # If "-" or "", an available docker host will automatically be found.
            # If "automount", an available docker host will automatically be found and mounted in the job container (e.g. /var/run/docker.sock).
            # Otherwise the specified docker host will be used and an error will be returned if it doesn't work.
            # docker_host = "-";

            # Pull docker image(s) even if already present
            force_pull = false;

            # Rebuild local docker image(s) even if already present
            force_rebuild = false;
          };

          host = {
            # The parent directory of a job's working directory.
            # If it's empty, $HOME/.cache/act/ will be used.
            # workdir_parent = "";
          };
        };
      };
    };

    virtualisation.podman = {
      enable = true;
      dockerSocket.enable = true;
    };
  };

  age.secrets.forgejo-runner-registration-token = {
    rekeyFile = "${inputs.self.outPath}/secrets/forgejo-runner-registration-token.age";
    path = "${microvmSecretsDir}/forgejo-runner-registration-token";
    symlink = false; # Required since the vm can't see the target if it's a symlink
    mode = "600"; # Allow the VM's root to chown it for forgejo user
    owner = "microvm";
    group = "kvm";
  };
}
