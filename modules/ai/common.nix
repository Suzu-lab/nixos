# Shared plumbing for the three containerized AI stacks (companion, imagegen, roleplay).
#
# The stacks stay deliberately independent — separate compose projects, separate host modules, each
# enableable on its own. But they are not *unrelated*: all three live on the same AI NVMe and all
# three create their data dirs the same way. Those two facts were previously copy-pasted into each
# host module, which meant `dataDir` had three identical declarations that could silently drift
# apart (change one default, the other two keep the old path and nothing warns you).
#
# This module owns the shared facts. Per-stack modules consume them and keep everything else local.
{
  lib,
  username,
  ...
}:
let
  inherit (lib) mkOption types;
in
{
  options.suzu.ai = {
    dataDir = mkOption {
      type = types.str;
      default = "/home/${username}/ai-models";
      example = "/mnt/nvme/ai";
      description = ''
        Base directory on the dedicated AI NVMe, shared by every AI stack. Each stack puts its
        models and per-service container volumes in a subdirectory of this (models/, olv/,
        imagegen/, roleplay/, …). Reuses the existing mount from suzu.system.disks.

        This is the single source of truth: the per-stack `suzu.ai.*Host.dataDir` options all
        default to it, so pointing the AI data at a different disk is a one-line change here.
        It must also match AI_MODELS_ROOT in modules/ai/imagegen/.env, which the compose
        projects read.
      '';
    };

    mkDirs = mkOption {
      internal = true;
      readOnly = true;
      type = types.raw;
      description = ''
        Helper: builds systemd.tmpfiles rules creating <root>/<subdir> owned by the primary user,
        so imperative docker/hf work in those trees needs no sudo. Used by every AI host module —
        centralized so the mode/owner triple is stated once instead of four times.

        Usage: `systemd.tmpfiles.rules = config.suzu.ai.mkDirs cfg.dataDir [ "models" "olv" ];`
      '';
      default = root: subdirs: map (d: "d ${root}/${d} 0755 ${username} users -") subdirs;
    };
  };
}
