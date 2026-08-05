# Copyparty — web file manager for phone access to my files. Bound to 127.0.0.1:8091 and published
# on the tailnet at :5443 by `tailscale serve`; nixos/tailscale.nix owns that serve table and the
# `suzu.system.remoteAccess.enable` flag this module gates on.
#
# WHY IT REPLACED FILEBROWSER: Filebrowser ran with `root = /home/suzu` and `noauth = true`, so any
# device on the tailnet could read ~/.ssh AND the sops age key that decrypts every secret in this
# repo. Copyparty is still unauthenticated — the tailnet stays the security boundary, same as the
# rest of the phone panel — but the exposure is now bounded by an explicit allowlist instead of the
# whole home. The upstream module runs the service under `TemporaryFileSystem = "/:ro"`, so ONLY the
# paths listed in `volumes` below are bind-mounted into its namespace. Dotfiles, ~/.ssh and
# ~/.config/sops simply do not exist as far as this process is concerned — unreachable even if
# copyparty itself were compromised. That sandbox, not the uid, is what does the work here.
#
# The module comes from copyparty's own flake: nixpkgs has the package but not `services.copyparty`
# (see the input comment in flake.nix).
{
  config,
  inputs,
  lib,
  username,
  utils,
  ...
}:
let
  cfg = config.suzu.system.remoteAccess;
  home = "/home/${username}";

  # rwmd = read + write + move + delete, granted to "*" (anonymous — there are no accounts). Same
  # power Filebrowser handed out; the restriction that matters is WHICH paths exist, not what you
  # can do inside them. NOTE: "*" must stay unquoted in the generated config — a literal `"*"` is
  # read as an account NAME and copyparty refuses to start ("you must -a the following users").
  # The module's generator emits bare strings, so this is correct as written.
  rw = { rwmd = "*"; };
in
{
  imports = [ inputs.copyparty.nixosModules.default ];

  config = lib.mkIf cfg.enable {
    services.copyparty = {
      enable = true;

      # Runs as me rather than a dedicated system user: /home/suzu is 0700, so a `copyparty` user
      # couldn't even traverse into the volumes below, and this way uploads land owned by me with no
      # chown dance. Since user != "copyparty" the module skips creating the account — `suzu` and
      # `users` both already exist.
      user = username;
      group = "users";

      # `copyparty-hash` exists only to pre-hash account passwords, and there are no accounts.
      mkHashWrapper = false;

      settings = {
        i = "127.0.0.1"; # localhost only — `tailscale serve` is the sole way in
        p = 8091;
        no-reload = true;
        # Thumbnail/index databases land here instead of a .hist folder inside every shared
        # directory. Presence of this key is also what makes the module set up CacheDirectory=.
        hist = "/var/cache/copyparty";
      };

      # Content indexing (`e2dsa`, and `e2ts` for media tags) is deliberately OFF: it hashes every
      # file on first run, which on the 12 TB hdd volume means hours of disk churn for a search box
      # I'd rarely use. Browsing, uploads and thumbnails all work without it. To enable it for one
      # volume, add `flags.e2dsa = true;` to that volume below.
      #
      # PATHS MUST BE STRINGS, NOT NIX PATH LITERALS. The upstream module interpolates
      # `${attrs.path}` into the generated config file; interpolating a path literal would copy the
      # entire directory into the nix store (world-readable) — dropping the quotes around
      # "${home}/hdd" would try to import 12 TB.
      #
      # There is intentionally no volume at "/": copyparty then serves a virtual root listing made
      # up of exactly these entries, which is the landing page you get on the phone.
      volumes = {
        "/downloads" = { path = "${home}/Downloads"; access = rw; };
        "/documents" = { path = "${home}/Documents"; access = rw; };
        "/pictures" = { path = "${home}/Pictures"; access = rw; };
        "/screenshots" = { path = "${home}/Screenshots"; access = rw; };
        "/videos" = { path = "${home}/Videos"; access = rw; };
        "/music" = { path = "${home}/Music"; access = rw; };
        "/wallpapers" = { path = "${home}/Wallpapers"; access = rw; };
        "/hdd" = { path = "${home}/hdd"; access = rw; };
      };
    };

    # The hdd volume is a separate btrfs disk mounted `nofail` (see nixos/disks.nix), so it can come
    # up after this service would otherwise start — and a bind mount taken before the disk is
    # mounted keeps showing the empty directory underneath forever, since later mounts don't
    # propagate into an existing namespace. Ordering-only (After=, not Requires=/RequiresMountsFor=)
    # on purpose: `nofail` says the box must boot without that disk, so a dead HDD should cost me
    # the /hdd volume, not the whole file server.
    systemd.services.copyparty.after = [ "${utils.escapeSystemdPath "${home}/hdd"}.mount" ];
  };
}
