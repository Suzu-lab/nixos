# Host firewall. Default-deny inbound; the only thing this module does is turn it on.
#
# Inbound ports are deliberately NOT opened here. Anything that needs one declares it next to the
# thing that needs it (e.g. the tailnet-scoped ports in nixos/tailscale.nix, which are bound to
# `-i tailscale0` so they're invisible to the LAN), so every hole in the firewall sits beside its
# own justification instead of accumulating in a central list nobody can audit.
{ config, lib, ... }:
let
  cfg = config.suzu.system.firewall;
in
{
  options.suzu.system.firewall.enable =
    lib.mkEnableOption "Host firewall (default-deny inbound)";

  config = lib.mkIf cfg.enable {
    networking.firewall.enable = true;

    # REMOVED 2026-08-04: `allowedUDPPortRanges = [ { from = 10000; to = 60000; } ]`, commented
    # here as "Open ports needed for Discord RTC". It was never needed, and it was actively harmful:
    #
    #   - Discord voice is initiated OUTBOUND by the client — it opens the UDP flow toward Discord's
    #     voice server. The replies already come back through the firewall's RELATED,ESTABLISHED
    #     conntrack rule. A client behind NAT needs zero inbound accepts for it. The "open
    #     10000-60000" advice found in forums is for people HOSTING, or misdiagnosing NAT.
    #   - This kernel's ephemeral port range is 32768-60999, so the rule overlapped nearly all of
    #     it: every outbound connection's source port doubled as an open inbound door for its
    #     lifetime.
    #   - Concretely exposed to the whole house LAN (shared with other people's IoT): qBittorrent's
    #     UDP port, the browser's WebRTC sockets, Steam's 27036.
    #
    # If some UDP service ever genuinely needs an inbound port, open THAT port, scoped to an
    # interface where possible — never a range.
  };
}
