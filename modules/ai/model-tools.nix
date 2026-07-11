# Model-download tooling shared by all three AI stacks (companion, imagegen, roleplay). Kept as its
# own module because it's cross-cutting — every stack pulls weights — and none of the per-stack host
# modules is the natural owner.
#
#   hf              — Hugging Face Hub CLI (from python3Packages.huggingface-hub). Downloads GGUFs
#                     and HF-hosted checkpoints. Modern name; `huggingface-cli` is the deprecated alias.
#   hf-transfer     — Rust-accelerated parallel downloader. MUST live in the SAME python env as
#                     huggingface-hub to take effect, hence the withPackages wrapper (not two separate
#                     packages). Enabled via HF_HUB_ENABLE_HF_TRANSFER below.
#   aria2 (aria2c)  — resumable, multi-connection downloader. Used for CivitAI (which is NOT on the HF
#                     Hub, so `hf` can't fetch it) and for any big direct-URL weights. `-x8 -s8 -c`.
#   civitai-dl      — thin aria2c wrapper that injects the sops-managed CivitAI token as an auth
#                     header ONLY for CivitAI (never a global aria2.conf header, which would leak the
#                     token to every host). Token is passed via a 0600 tmpfs conf file, not argv, so
#                     it never shows in `ps`. Usage: civitai-dl <version-id|url> [dest-dir] [filename].
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.suzu.ai.modelTools;
  inherit (lib) mkEnableOption mkIf;
in
{
  options.suzu.ai.modelTools.enable =
    mkEnableOption "Model-download tooling (hf + hf-transfer + aria2) shared by the AI stacks";

  config = mkIf cfg.enable {
    environment.systemPackages = [
      (pkgs.python3.withPackages (ps: with ps; [ huggingface-hub hf-transfer ]))
      pkgs.aria2
      # CivitAI downloader that pulls the token from sops (/run/secrets/civitai_api_token) instead of
      # the command line. The header goes via a 0600 file in $XDG_RUNTIME_DIR (tmpfs), so the token
      # never lands in argv/`ps` or shell history, and it's sent to CivitAI only.
      (pkgs.writeShellApplication {
        name = "civitai-dl";
        runtimeInputs = with pkgs; [ aria2 coreutils ];
        text = ''
          # usage: civitai-dl <version-id|civitai-url> [dest-dir] [filename]
          tok=/run/secrets/civitai_api_token
          [ -r "$tok" ] || { echo "civitai-dl: cannot read $tok (sops secret not materialized?)" >&2; exit 1; }
          arg=''${1:?usage: civitai-dl <version-id|civitai-url> [dest-dir] [filename]}
          case "$arg" in
            http*) url=$arg ;;
            *)     url="https://civitai.com/api/download/models/$arg" ;;
          esac
          dest=''${2:-.}
          out=''${3:-}

          conf=$(mktemp "''${XDG_RUNTIME_DIR:-/tmp}/civitai-dl.XXXXXX")
          trap 'rm -f "$conf"' EXIT
          printf 'header=Authorization: Bearer %s\n' "$(cat "$tok")" > "$conf"

          # shellcheck disable=SC2086  # $out is intentionally unquoted so empty = omit -o
          aria2c --conf-path="$conf" -x8 -s8 -c --content-disposition-default-utf8=true \
            -d "$dest" ''${out:+-o "$out"} "$url"
        '';
      })
    ];
    environment.variables = {
      # Turn on the fast HF downloader globally (harmless when hf-transfer isn't the one downloading).
      HF_HUB_ENABLE_HF_TRANSFER = "1";
      # Point hf at the sops-managed token FILE (not the value) — authenticated downloads without the
      # secret ever landing in the nix store. sops materializes it at /run/secrets/hf_token (declared
      # in modules/nixos/secrets.nix). If the file is absent, hf simply falls back to anonymous.
      HF_TOKEN_PATH = config.sops.secrets.hf_token.path;
    };
  };
}
