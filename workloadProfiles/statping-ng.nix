{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  personal-data,
  ...
}: {
  services.caddy.virtualHosts."status.hepr.me".extraConfig = ''
    tls /var/lib/acme/hepr.me/cert.pem /var/lib/acme/hepr.me/key.pem

    @denied not client_ip 192.168.0.0/16 100.80.81.0/24
    respond @denied 200

    reverse_proxy :42100
  '';

  virtualisation.oci-containers = {
    backend = "podman";
    containers.statping-ng = {
      imageFile = pkgs.dockerTools.pullImage {
        imageName = "adamboutcher/statping-ng";
        imageDigest = "sha256:e32bd2e50ca023f37b0650e1942d51cb9269a2caab11042bc0cc53fac0474a2b";
        sha256 = "16q341rvqc0a7cq3q1qbbk4h1pll76hny7m7xdhfj43raz1d2ppk";
        finalImageName = "adamboutcher/statping-ng";
        finalImageTag = "latest";
      };
      image = "adamboutcher/statping-ng";
      ports = ["42100:8080"]; # 42100 host -> 8080 container
      volumes = ["/var/lib/statping-ng:/app"];
      environment = {};
      # user = "statping-ng:statping-ng";
    };
  };
  # users.users.statping-ng = {
  #   isSystemUser = true;
  #   group = "statping-ng";
  # };
  # users.groups.statping-ng = {};
}
