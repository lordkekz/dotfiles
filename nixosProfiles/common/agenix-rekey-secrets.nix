# Config für agenix-rekey hosts
{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  age.rekey = {
    masterIdentities = [
      {
        identity = ../../secrets/3r1p.hmac;
        pubkey = "age14nkxgl7setmn2tk6yv9dup72fufc6hvysaqzz80ue0zhv2e63gjskafml8";
      }
    ];

    storageMode = "local";

    # Choose a directory to store the rekeyed secrets for this host.
    # This cannot be shared with other hosts. Please refer to this path
    # from your flake's root directory and not by a direct path literal like ./secrets
    localStorageDir = "${inputs.self.outPath}/secrets/rekeyed/${config.networking.hostName}";

    # Required for FIDO2 key (according to agenix-rekey README)
    agePlugins = [pkgs.age-plugin-fido2-hmac];
  };

  age.identityPaths = ["/home/hpreiser/.ssh/id_ed25519"];
}
