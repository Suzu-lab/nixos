{ 
  config, 
  lib, 
  pkgs, 
  ... 
}:

let
  cfg = config.suzu.networking;
in
{
  options.suzu.networking = {
    enable = lib.mkEnableOption "Custom networking setup with DoH and fallback";

    doh.enable = lib.mkEnableOption "Enable DNS-over-HTTPS via dnscrypt-proxy2 (Cloudflare)";
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
        ipv6_servers = true;      # Requires resolvers with ipv6 support
        block_ipv6   = false;
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
