{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  personal-data,
  ...
}: {
  services.caddy.virtualHosts."frigate.hepr.me".extraConfig = ''
    tls /var/lib/acme/hepr.me/cert.pem /var/lib/acme/hepr.me/key.pem
    reverse_proxy :4080
  '';

  services.frigate = {
    enable = true;
    settings = {
      cameras = {
        front-1 = {
          enabled = true;
          ffmpeg.inputs = [
            {
              path = "rtsp://{FRIGATE_RTSP_USER}:{FRIGATE_RTSP_FRONT_PASSWORD}@{FRIGATE_RTSP_FRONT_IP}/axis-media/media.amp?camera=1";
              roles = ["record" "detect"];
            }
          ];
        };
        front-2 = {
          enabled = true;
          ffmpeg.inputs = [
            {
              path = "rtsp://{FRIGATE_RTSP_USER}:{FRIGATE_RTSP_FRONT_PASSWORD}@{FRIGATE_RTSP_FRONT_IP}/axis-media/media.amp?camera=2";
              roles = ["record" "detect"];
            }
          ];
        };
      };
      record = {
        enabled = true;
        retain.days = 30;
        retain.mode = "all";
      };
    };
    hostname = "frigate.hepr.me";
  };

  systemd.services.frigate.serviceConfig.EnvironmentFile = config.age.secrets.frigate-rtsp-passwords.path;
  age.secrets.frigate-rtsp-passwords.rekeyFile = "${inputs.self.outPath}/secrets/frigate-rtsp-passwords.age";

  # Let nginx listen on different ports because the main ports are used by caddy
  services.nginx = {
    defaultHTTPListenPort = 4080;
    defaultSSLListenPort = 4443;
  };
}
