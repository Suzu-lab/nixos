# Module for configuring ComfyUI.
# See https://comfyui-wiki.com/en/install/install-comfyui/install-comfyui-on-linux, method 1 (Install with comfy-cli)
{ 
  config, 
  inputs,
  lib, 
  pkgs,
  hm, 
  ... 
}:
let
  cfg = config.suzu.ai.comfyui;
  inherit (lib) mkEnableOption mkIf mkOption types;

  # Use "string" instead of "path" for the work paths to avoid NixOS basing the paths on the store
  envDir = cfg.envDir;
  workspaceDir = cfg.workspaceDir;

  # Declare path for common libs PyTorch needs so it can actually find it
  rocmLibs = lib.makeLibraryPath [
    pkgs.bzip2
    pkgs.libffi
    pkgs.openssl
    pkgs.stdenv.cc.cc.lib
    pkgs.uv
    pkgs.xz
    pkgs.zlib
    pkgs.zstd

    pkgs.rocmPackages.clr
    pkgs.rocmPackages.hipcc
    pkgs.rocmPackages.hsakmt
    pkgs.rocmPackages.rocm-device-libs
  ];

  # Creating a declarative fingerprint so ComfyUI will only reinstall if anything changes
  bootstrapFingerprint =
    builtins.hashString "sha256" (builtins.toJSON {
      envDir       = envDir;
      workspaceDir = workspaceDir;
      python       = pkgs.python312.version;
      torchIndex   = "https://download.pytorch.org/whl/rocm6.4";
    }
  );

  # Using a markerfile to save the old fingerprint
  markerFile = "${envDir}/.bootstrap-fingerprint";

  # Using writeShellScript to create the bootstrap service exec script
  bootstrapScript = pkgs.writeShellScript "comfyui-bootstrap" ''
    set -euo pipefail
  
    # Using the markerfile and the fingerprint to decide if the bootstrap script must run
    MARKER="${markerFile}"
    CURRENT_FP="${bootstrapFingerprint}"

    NEEDS=0

    # Runs again if either the venv directory or the ComfyUI directory don't exist
    if [ ! -d "${envDir}" ] || [ ! -d "${workspaceDir}" ]; then
      NEEDS=1
    # Also runs again if the markerfile doesn't exist
    elif [ ! -f "$MARKER" ]; then
      NEEDS=1
    else
    # And finally, runs again if the current fingerprint is different from the old one that is inside the markerfile
      OLD_FP="$(cat "$MARKER" 2>/dev/null || echo)"
      [ "$OLD_FP" != "$CURRENT_FP" ] && NEEDS=1
    fi

    # If none of the previous things happened, then it just exits and skips the whole script
    if [ "$NEEDS" -eq 0 ]; then
      echo "[comfyui-bootstrap] Nothing changed, skipping bootstrap."
      exit 0
    fi

    # Tools (don't assume PATH in HM activation)
    CAT="${pkgs.coreutils}/bin/cat"
    GREP="${pkgs.gnugrep}/bin/grep"
    PERL="${pkgs.perl}/bin/perl"

    # Shortcuts for venv binaries
    PIP="${cfg.envDir}/bin/pip"
    COMFY="${cfg.envDir}/bin/comfy"
    PYTHON="${pkgs.python312}/bin/python3"
    UV="${pkgs.uv}/bin/uv"
    VENV_UV="${cfg.envDir}/bin/uv"
    LN="${pkgs.coreutils}/bin/ln"
    RM="${pkgs.coreutils}/bin/rm"

    echo "[comfyui-bootstrap] Creating venv in ${cfg.envDir} (if it doesn't exist)..."
    if [ ! -d "${cfg.envDir}/bin" ]; then
      "$PYTHON" -m venv "${cfg.envDir}"
    fi

    if [ ! -x "$VENV_UV" ]; then
      echo "[bootstrap] Linking uv into venv..."
      "$RM" -f "$VENV_UV" || true
      "$LN" -s "$UV" "$VENV_UV"
    fi

    # Guarantees python and comfy-cli can see git
    export GIT_PYTHON_GIT_EXECUTABLE="${pkgs.git}/bin/git"
    export PATH="${pkgs.git}/bin:${PATH:-}"

    echo "[comfyui-bootstrap] Updating pip..."
    "$PIP" install --upgrade pip setuptools wheel

    echo "[comfyui-bootstrap] Installing PyTorch ROCm..." 
    # Version number must be defined manually for update
    "$PIP" install torch torchvision torchaudio \
      --index-url https://download.pytorch.org/whl/rocm6.4

    # Patching venv activate scripts to add the library paths
    ACT="${cfg.envDir}/bin/activate"
    ACT_F="${cfg.envDir}/bin/activate.fish"

    # bash patch
    if "$GREP" -q "^# ROCM_LIBS_PATCH_BEGIN$" "$ACT"; then
      echo "[bootstrap] Removing old activate patch…"
      "$PERL" -0777 -i -pe 's/\n?# ROCM_LIBS_PATCH_BEGIN.*?# ROCM_LIBS_PATCH_END\n?//s' "$ACT"
    fi

    echo "[bootstrap] Ensuring activate patch…"
    "$CAT" >> "$ACT" <<EOF

# ROCM_LIBS_PATCH_BEGIN
export LD_LIBRARY_PATH="${rocmLibs}:\$LD_LIBRARY_PATH"
# ROCM_LIBS_PATCH_END
EOF

    # fish patch
    if "$GREP" -q "^# ROCM_LIBS_PATCH_BEGIN$" "$ACT_F"; then
      echo "[bootstrap] Removing old activate.fish patch…"
      "$PERL" -0777 -i -pe 's/\n?# ROCM_LIBS_PATCH_BEGIN.*?# ROCM_LIBS_PATCH_END\n?//s' "$ACT_F"
    fi

    echo "[bootstrap] Ensuring activate.fish patch…"
    "$CAT" >> "$ACT_F" <<EOF

# ROCM_LIBS_PATCH_BEGIN
set -gx LD_LIBRARY_PATH "${rocmLibs}:\$LD_LIBRARY_PATH"
# ROCM_LIBS_PATCH_END
EOF

    echo "[comfyui-bootstrap] Installing comfy-cli in venv..."
    "$PIP" install comfy-cli


    echo "[comfyui-bootstrap] Verifying ComfyUI install..."
    if [ ! -d "${cfg.workspaceDir}" ]; then
      echo "[comfyui-bootstrap] Installing ComfyUI in ${cfg.workspaceDir}..."
      "$COMFY" --skip-prompt --no-enable-telemetry \
        --workspace="${cfg.workspaceDir}" \
        install --amd
    else
      echo "[comfyui-bootstrap] ComfyUI already installed in ${cfg.workspaceDir}..."
    fi

    echo "$CURRENT_FP" > "$MARKER"
    echo "[comfyui-bootstrap] Done!"
  '';

# Using writeShellScript to create the ComfyUI service exec script
runScript = pkgs.writeShellScript "comfyui-run" ''
        set -euo pipefail

        PY="${envDir}/bin/python"
        export LD_LIBRARY_PATH="${rocmLibs}:\$LD_LIBRARY_PATH"

        export GIT_PYTHON_GIT_EXECUTABLE="${pkgs.git}/bin/git"
        export PATH="${pkgs.uv}/bin:${pkgs.python312Packages.uv}/bin:${pkgs.git}/bin:${PATH:-}"

        cd "${workspaceDir}"

        exec "$PY" main.py --listen 127.0.0.1 --port ${toString cfg.port}
#        COMFY="${envDir}/bin/comfy"

        # Guarantees python and comfy-cli can see git
#        export GIT_PYTHON_GIT_EXECUTABLE="${pkgs.git}/bin/git"
#        export PATH="${pkgs.git}/bin:${PATH:-}"

#        if [ ! -x "$COMFY" ]; then
#          echo "ERROR: comfy-cli não encontrado em $COMFY" >&2
#          exit 1
#        fi

#        echo "[comfyui] Starting ComfyUI in workspace ${workspaceDir}..."
#        exec "$COMFY" --workspace="${workspaceDir}" \
#          launch -- --listen 0.0.0.0 --port ${toString cfg.port}
      '';

in
{
  options.suzu.ai.comfyui = {
    enable = mkEnableOption "Enable ComfyUI with AMD ROCm";

    # ComfyUI venv location
    envDir = mkOption {
      type = types.path;
      default = "~/.local/share/comfy-env";
      description = "Virtualenv used by comfy-cli / ComfyUI.";
    };

    # Installation directory of ComfyUI (it will be installed in <workspaceDir>/ComfyUI)
    workspaceDir = mkOption {
      type = types.path;
      default = "~/ai/comfyui";
      description = "Path to the ComfyUI install folder.";
    };

    openFirewall = mkOption {
      type = types.bool;
      default = false;
      description = "Open firewall port for external access to ComfyUI.";
    };

    port = mkOption {
      type = types.int;
      default = 8188;
      description = "Firewall port to open.";
    };
  };

  config = mkIf cfg.enable {
    # Install python and dependencies to create virtual environment
    environment.systemPackages = with pkgs; [
      git
      python312
      python312Packages.pip
      python312Packages.uv
      python312Packages.virtualenv

      bzip2
      libffi
      openssl
      stdenv.cc.cc.lib
      uv
      xz
      zlib
      zstd
      
      # ROCm tools
      rocmPackages.clr
      rocmPackages.hipcc
      rocmPackages.hsakmt
      rocmPackages.rocm-device-libs
    ];

    # Use tmpfiles to create needed directories for the service
    systemd.tmpfiles.rules = [
      "d ${cfg.envDir} 0777 suzu users -"
    ];

    # One shot systemd service for creating venv and ComfyUI install, done through home-manager
    hm.home.activation.comfyui-bootstrap =
      inputs.home-manager.lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          ${bootstrapScript}
        '';

    # Creating main ComfyUI systemd service
    systemd.user.services.comfyui = {
      enable = true;
      description = "ComfyUI (via comfy-cli)";
      after = [ "graphical-session.target" ];
      wants = [ "graphical-session.target" ];
      wantedBy = [ "graphical-session.target" ];

      environment = {
        LD_LIBRARY_PATH = rocmLibs;
      };
      
      serviceConfig = {
        Type = "simple";
        WorkingDirectory = cfg.workspaceDir;
        Restart = "on-failure";
        RestartSec = "3";
        ExecStart = "${runScript}";
      };      
    };

    # Opening firewall (optional)
    networking.firewall.allowedTCPPorts = mkIf cfg.openFirewall [ cfg.port ];
  };
}