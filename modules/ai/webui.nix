{ 
  config, 
  lib, 
  pkgs, 
  ... 
}:
let
  cfg = config.suzu.ai.webui;

  inherit (lib) mkEnableOption mkIf mkOption types;
in
{
  options.suzu.ai.webui = {
    enable = mkEnableOption "Enables OpenUI webui for accessing ollama";

    openFirewall = mkOption {
      type = types.bool;
      default = false;
      description = "If true, opens firewall port to allow external access to OpenUI.";
    };
  };
  config = mkIf cfg.enable {
    services.open-webui = {
      enable = true;

      environment = {
        OLLAMA_API_BASE_URL = "http://127.0.0.1:11434/api";
        OLLAMA_BASE_URL     = "http://127.0.0.1:11434";
        ANONYMIZED_TELEMETRY = "False";
        DO_NOT_TRACK = "True";
      };
      openFirewall = cfg.openFirewall;
    };
  };
}