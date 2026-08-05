# Tailscale mesh VPN + phone access to the local services, centralized here because it spans all
# three AI stacks (companion, imagegen, roleplay) plus system stats — not any one stack's concern.
#
# POSTURE: every service is bound to 127.0.0.1 in its own compose/module (nothing published on the
# LAN). `tailscale serve` then proxies each onto the TAILNET over HTTPS. Net effect:
#   - Public internet: unreachable (plain Tailscale is a private mesh, not Funnel; no port-forward).
#   - LAN: unreachable (localhost binds; serve doesn't touch the host firewall).
#   - Tailnet: reachable by YOUR authenticated devices only (your phone).
# So the phone reaches everything from anywhere over the internet via Tailscale's encrypted tunnel
# (direct WireGuard, DERP relay fallback), and nothing else can.
#
# ONE-TIME MANUAL STEPS (nothing is exposed until you do them):
#   1. `sudo tailscale up`                      — authenticate this host onto your tailnet.
#   2. Admin console → enable MagicDNS + HTTPS   — lets `serve` provision TLS certs (free).
#   3. Install Tailscale on the phone, same login. Optionally disable this host's key expiry.
# After that the `tailscale-serve` unit below applies the proxy mappings on every activation/boot.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.suzu.system.remoteAccess;
  ts = "${config.services.tailscale.package}/bin/tailscale";

  # Phone control panel binary (the server itself is cockpit/cockpit.py). Referenced twice below:
  # installed on PATH for manual/debug runs, and as the ExecStart of the systemd user service.
  ai-cockpit = pkgs.writeShellApplication {
    name = "ai-cockpit";
    runtimeInputs = [ pkgs.python3 ];
    text = "exec python3 ${./cockpit/cockpit.py}";
  };

  # service → tailnet HTTPS port. Distinct ports (not path prefixes) because SwarmUI, netdata and
  # the llama-swap dashboards all use absolute asset paths, which a path-prefix proxy would break.
  # On the phone you bookmark https://<host>.<tailnet>.ts.net[:port] per service (MagicDNS name).
  serves = [
    { port = 443;  target = "http://127.0.0.1:8090";  desc = "ai-cockpit (control panel — landing page)"; }
    { port = 5443; target = "http://127.0.0.1:8091";  desc = "Copyparty (file access — see nixos/copyparty.nix)"; }
    { port = 6443; target = "http://127.0.0.1:8000";  desc = "SillyTavern (roleplay)"; }
    { port = 8443; target = "http://127.0.0.1:8081";  desc = "llama-swap dashboard (RP backend)"; }
    { port = 7443; target = "http://127.0.0.1:7801";  desc = "SwarmUI (image generation)"; }
    { port = 9443; target = "http://127.0.0.1:19999"; desc = "netdata (GPU/VRAM/host stats)"; }
  ];
  serveLines = lib.concatMapStringsSep "\n"
    (s: "\"$ts\" serve --bg --https=${toString s.port} ${s.target}   # ${s.desc}") serves;
in
{
  options.suzu.system.remoteAccess.enable =
    lib.mkEnableOption "Tailscale + phone access (serve) for the local AI stacks and stats";

  config = lib.mkIf cfg.enable {
    services.tailscale.enable = true;

    # serve listens as REAL kernel sockets on the tailscale IP (100.x:443, :6443, …), so inbound TCP
    # from the tailnet must pass the host firewall — without this, peers can ping (ICMP) but every
    # TCP connection is silently dropped by the default-deny policy. Opened ONLY on tailscale0, and
    # derived from the serve list so the ports never drift out of sync with the mappings above.
    networking.firewall.interfaces."tailscale0".allowedTCPPorts = map (s: s.port) serves;

    # The phone control panel (served on :443 above). A tiny HTTP server on 127.0.0.1:8090; the
    # actual command execution and stats-reading live in cockpit/cockpit.py. Installed on PATH here
    # (handy for manual runs), and autostarted as the systemd user service below.
    environment.systemPackages = [ ai-cockpit ];

    # Autostart as a systemd USER service bound to the niri graphical session (replaces the old niri
    # spawn-at-startup in modules/desktop/niri/niri.nix). graphical-session.target is only reached
    # AFTER niri-session imports WAYLAND_DISPLAY + NIRI_SOCKET + DBUS into the --user environment, so
    # this inherits exactly the session env the spawn had — docker + niri/noctalia for its gpu/display
    # actions. Wins over the spawn: `nixos-rebuild switch` restarts it on every cockpit.py change, and
    # you get `systemctl --user restart ai-cockpit` + journal logs instead of a bare orphan process.
    systemd.user.services.ai-cockpit = {
      description = "ai-cockpit phone control panel (127.0.0.1:8090)";
      partOf = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      wantedBy = [ "graphical-session.target" ];
      # The action buttons shell out to the same CLIs the stream deck uses (companion-ctl, rp-on/off,
      # imagegen-ctl), which live in the system profile. As a niri spawn the cockpit inherited the
      # session PATH; a systemd user service gets only the minimal systemd-user PATH, so hand it the
      # system profile explicitly — otherwise `subprocess.run(["companion-ctl", …])` is FileNotFound.
      # /run/wrappers must come FIRST: there is a `sudo` in /run/current-system/sw/bin too, but it
      # is not the setuid wrapper, so it dies with "must be owned by uid 0 and have the setuid bit
      # set" and exits 1 — indistinguishable from a normal command failure. The cockpit needs real
      # sudo for the Proton VPN controls (switching exit nodes and reading the kill-switch chain).
      path = [
        "/run/wrappers"
        "/run/current-system/sw"
      ];
      serviceConfig = {
        ExecStart = lib.getExe ai-cockpit;
        Restart = "on-failure";
        RestartSec = 2;
      };
    };

    # The file server behind :5443 is Copyparty, configured in nixos/copyparty.nix (it gates on this
    # same `remoteAccess.enable` flag). It used to be Filebrowser, declared right here — see that
    # module's header for why it was swapped out.

    # Apply the serve mappings once the node is authenticated & up. `serve reset` first so this unit
    # is the single source of truth (drops any stale mappings); RemainAfterExit keeps it "active".
    # Idempotent: safe to re-run on every rebuild/boot. Best-effort before `tailscale up` — it just
    # waits out the loop and exits; the next activation after you authenticate applies it for real.
    systemd.services.tailscale-serve = {
      description = "Expose local services on the tailnet via tailscale serve";
      after = [ "tailscaled.service" "network-online.target" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
      # Re-apply whenever tailscaled itself restarts. Serve mappings live in tailscaled's state, so
      # anything that resets it (a restart, or a logout like the one the IPv6 bug caused) drops all
      # of them silently — the phone just gets connection-refused with nothing in any log.
      partOf = [ "tailscaled.service" ];
      # No start-rate limit: the retry below may legitimately need many attempts on a slow boot, or
      # forever if the node was never authenticated.
      unitConfig.StartLimitIntervalSec = 0;
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        # Keep retrying until tailscale is actually up. This unit used to give up after ~60s and
        # exit 0, which left the box "active" with zero mappings — exactly what happened on the
        # 2026-08-05 boot where tailscaled couldn't reach the control plane. Failing loudly and
        # retrying is what makes it self-heal instead of needing a manual restart.
        Restart = "on-failure";
        RestartSec = 30;
        ExecStart = pkgs.writeShellScript "tailscale-serve-up" ''
          set -euo pipefail
          ts=${ts}
          # Wait (max ~60s) for the node to be authenticated & Running after a boot / `tailscale up`.
          for _ in $(seq 1 30); do
            if "$ts" status --json 2>/dev/null | ${pkgs.jq}/bin/jq -e '.BackendState=="Running"' >/dev/null; then
              break
            fi
            sleep 2
          done
          "$ts" status --json 2>/dev/null | ${pkgs.jq}/bin/jq -e '.BackendState=="Running"' >/dev/null || {
            echo "tailscale not Running yet (run 'sudo tailscale up'); will retry." >&2
            exit 1
          }
          "$ts" serve reset
          ${serveLines}
        '';
        ExecStop = "${ts} serve reset";
      };
    };
  };
}
