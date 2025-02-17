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
              path = "rtsp://{FRIGATE_RTSP_USER}:{FRIGATE_RTSP_FRONT_PASSWORD}@{FRIGATE_RTSP_FRONT_IP}/axis-media/media.amp?camera=1&audio=1";
              roles = ["record"];
            }
          ];
        };
        front-2 = {
          enabled = true;
          ffmpeg.inputs = [
            {
              path = "rtsp://{FRIGATE_RTSP_USER}:{FRIGATE_RTSP_FRONT_PASSWORD}@{FRIGATE_RTSP_FRONT_IP}/axis-media/media.amp?camera=5&audio=1";
              roles = ["record"];
            }
          ];
        };
        front-3 = {
          enabled = true;
          ffmpeg.inputs = [
            {
              path = "rtsp://{FRIGATE_RTSP_USER}:{FRIGATE_RTSP_FRONT_PASSWORD}@{FRIGATE_RTSP_FRONT_IP}/axis-media/media.amp?camera=6&audio=1";
              roles = ["record"];
            }
          ];
        };
        front-4 = {
          enabled = true;
          ffmpeg.inputs = [
            {
              path = "rtsp://{FRIGATE_RTSP_USER}:{FRIGATE_RTSP_FRONT_PASSWORD}@{FRIGATE_RTSP_FRONT_IP}/axis-media/media.amp?camera=7&audio=1";
              roles = ["record"];
            }
          ];
        };
        front-5 = {
          enabled = true;
          ffmpeg.inputs = [
            {
              path = "rtsp://{FRIGATE_RTSP_USER}:{FRIGATE_RTSP_FRONT_PASSWORD}@{FRIGATE_RTSP_FRONT_IP}/axis-media/media.amp?camera=8&audio=1";
              roles = ["record"];
            }
          ];
        };
      };
      record = {
        enabled = true;
        retain.days = 30;
        retain.mode = "all";
      };
      # detectors.ov = {
      #   type = "openvino";
      #   device = "GPU";
      # };
      # # FIXME see https://docs.frigate.video/configuration/object_detectors#ssdlite-mobilenet-v2
      # model = {
      #   width = 300;
      #   height = 300;
      #   input_tensor = "nhwc";
      #   input_pixel_format = "bgr";
      #   # FIXME build converted OpenVINO model, see:
      #   # https://github.com/blakeblackshear/frigate/blob/dev/docker/main/Dockerfile#L55
      #   # https://github.com/blakeblackshear/frigate/blob/dev/docker/main/requirements-ov.txt
      #   # https://github.com/blakeblackshear/frigate/blob/dev/docker/main/build_ov_model.py
      #   # path = ...;
      #   labelmap_path = "${config.services.frigate.package}/share/frigate/coco_91cl_bkgr.txt";
      # };
    };
    hostname = "frigate.hepr.me";
  };

  systemd.services.frigate.serviceConfig.After = ["zfs-mount.service"];
  systemd.services.frigate.serviceConfig.EnvironmentFile = config.age.secrets.frigate-rtsp-passwords.path;
  age.secrets.frigate-rtsp-passwords.rekeyFile = "${inputs.self.outPath}/secrets/frigate-rtsp-passwords.age";

  # Let nginx listen on different ports because the main ports are used by caddy
  services.nginx = {
    defaultHTTPListenPort = 4080;
    defaultSSLListenPort = 4443;
  };
}
