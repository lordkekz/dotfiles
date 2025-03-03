{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  personal-data,
  ...
}: {
  services.caddy.virtualHosts."ai-chat.hepr.me".extraConfig = ''
    tls /var/lib/acme/hepr.me/cert.pem /var/lib/acme/hepr.me/key.pem
    reverse_proxy :1784
  '';
  services.caddy.virtualHosts."ollama-api.hepr.me".extraConfig = ''
    tls /var/lib/acme/hepr.me/cert.pem /var/lib/acme/hepr.me/key.pem
    reverse_proxy :11434
  '';

  services.open-webui = {
    enable = true;
    port = 1784;
    host = "127.0.0.1";
    openFirewall = false;
    stateDir = "/var/lib/ai-stuff/open-webui"; # persist via impermanence
    environment = {
      # Customization
      # ENV = "prod";
      WEBUI_URL = "https://llm.hepr.me";
      # Connect to local Ollama backend
      ENABLE_OLLAMA_API = "True";
      OLLAMA_BASE_URL = "http://localhost:11434";
      # Disable authentication
      WEBUI_AUTH = "False";
      # Defaults for privacy
      ANONYMIZED_TELEMETRY = "False";
      DO_NOT_TRACK = "True";
      SCARF_NO_ANALYTICS = "True";
    };
  };

  services.ollama = {
    enable = true;
    port = 11434;
    host = "127.0.0.1";
    openFirewall = false;
    home = "/var/lib/ai-stuff/ollama"; # persist via impermanence
    loadModels = ["deepseek-r1:1.5b" "deepseek-r1:8b"];
  };
}
