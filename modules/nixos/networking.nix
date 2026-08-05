# NetworkManager + encrypted DNS.
#
# With `doh.enable`, dnscrypt-proxy2 runs as a local resolver on 127.0.0.1:53 and every lookup
# leaves this machine encrypted (DoH/DNSCrypt) instead of in the clear to the ISP's resolver.
# NetworkManager is set to `dns = "none"` so it can't overwrite that with DHCP-provided servers.
#
# WHICH resolver: deliberately none in particular. No `server_names` is set, so dnscrypt-proxy
# downloads the public-resolvers list, keeps only entries matching the three requirements below,
# and picks the lowest-latency one — out of ~640 live servers, and it may change on its own.
# Check the current pick with:  journalctl -u dnscrypt-proxy | grep "lowest initial latency"
# Trade-off: no single operator sees all your queries, but `require_nolog` is a claim in the
# resolver's own metadata, not something verifiable. Pin `server_names` if you'd rather know
# exactly who you're talking to.
#
# Tailscale sits in front of this: /etc/resolv.conf points at MagicDNS (100.100.100.100), which
# forwards non-tailnet queries to 127.0.0.1 here — so the DoH path stays in play, it isn't bypassed.
{
  config,
  lib,
  ...
}:

let
  cfg = config.suzu.networking;
in
{
  options.suzu.networking = {
    enable = lib.mkEnableOption "Custom networking setup with DoH and fallback";

    doh.enable = lib.mkEnableOption
      "encrypted DNS via a local dnscrypt-proxy2 resolver (auto-selected upstream, see header)";
    doh.port = lib.mkOption {
      type = lib.types.int;
      default = 53;
      description = "Local port for encrypted DNS resolver (dnscrypt-proxy2 listen port).";
    };
  };

  config = lib.mkIf cfg.enable {

    # NetworkManager
    networking = {
      networkmanager = {
        enable = true;

        # Disable DNS from DHCP server
        dns = "none";
      };

      # When doh is toggled on, it uses the local service for encrypted DNS. When it's off, it falls back to regular DNS providers
      nameservers =
        if cfg.doh.enable then
          [ "127.0.0.1" ]
        else
          [
            "9.9.9.9"   # Quad9
            "1.1.1.1"   # Cloudflare
            "8.8.8.8"   # Google
          ];
    };

    # dnscrypt-proxy
    services.dnscrypt-proxy = lib.mkIf cfg.doh.enable {
      enable = true;

      settings = {
        # TEMPORARILY false (2026-08-04). This machine lost global IPv6 when it moved behind the
        # OpenWrt router — it only has a ULA and there's no IPv6 default route, so reaching
        # resolvers over v6 just wastes attempts on unreachable addresses. Set back to `true` once
        # IPv6 is restored upstream (OpenWrt relay mode on wan6/lan).
        ipv6_servers = false;
        # Left as-is: AAAA answers still come back, and the resolver library skips them correctly
        # because there's no v6 default route. Setting this true would also need reverting later.
        block_ipv6 = false;
        require_dnssec = true;    # Requires resolvers with Secure DNS
        require_nolog = true;     # Requires resolvers that don't log queries
        require_nofilter = true;  # Requires resolvers that have no content filter
        # Public resolvers for dnscrypt
        sources.public-resolvers = {
          urls = [
            "https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v3/public-resolvers.md"
            "https://download.dnscrypt.info/resolvers-list/v3/public-resolvers.md"
          ];
          # Cache file for resolving DNS directly
          cache_file = "/var/lib/dnscrypt-proxy/public-resolvers.md";
          minisign_key = "RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3";
        };  
      };
    };
    systemd.services.dnscrypt-proxy.serviceConfig.StateDirectory = "dnscrypt-proxy";
  };
}
