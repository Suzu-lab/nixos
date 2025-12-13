{ 
  config, 
  lib, 
  pkgs, 
  ... 
}:
let
  cfg = config.suzu.ai.ollama;

  inherit (lib) mkEnableOption mkIf mkOption types;

  # Choose ollama package based on acceleration backend
  ollamaPkg = 
    if cfg.backend == "rocm" then (pkgs.ollama-rocm)
    else if cfg.backend == "vulkan" then (pkgs.ollama-vulkan)
    else if cfg.backend == "cpu" then (pkgs.ollama-cpu)
    else pkgs.ollama;
in
{
  # Creates the options 
  options.suzu.ai.ollama = {
    enable = mkEnableOption "Local AI stack (Ollama + opcional WebUI)";

    backend = mkOption {
      type = types.enum [ "cpu" "rocm" "vulkan" ];
      default = "rocm";
      description = ''
        Desired acceleration backend:
        - "cpu": default package with workload on CPU.
        - "rocm": uses ROCm for AMD GPU acceleration.
        - "vulkan": usesvulkan for generic GPU acceleration.
      '';
    };
    models = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "List of LLM models to load on services.ollama.loadModels.";
    };
  };

  config = mkIf cfg.enable {
  # Enable ROCM support for AI acceleration with the AMD card
    nixpkgs.config.rocmSupport = true;

    services.ollama = {
      enable = true;
      package = ollamaPkg;

      # Enables ollama locally
      host = "127.0.0.1";
      port = 11434;

      # Loaded models at service startup
      loadModels = cfg.models;
    };
  };
}