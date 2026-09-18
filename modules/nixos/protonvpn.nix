# Proton VPN full-tunnel over WireGuard, always on, with a fail-closed kill switch.
#
# COEXISTENCE WITH TAILSCALE — the postUp block below is load-bearing, do not delete it.
#
# A 0.0.0.0/0 tunnel will swallow the tailnet unless the ip rules are ordered correctly. The order
# we need (lower priority number is evaluated first):
#
#   5210: from all fwmark 0x80000/0xff0000 lookup main      <- tailscaled's own encrypted packets
#   5270: from all lookup 52                                 <- table 52 = routes to tailnet peers
#   32764: from all lookup main suppress_prefixlength 0      <- keeps specific routes (the LAN)
#   32765: not from all fwmark <mark> lookup <table>         <- everything else -> Proton
#
# WHAT WENT WRONG THE FIRST TIME (2026-08-05, cost one broken boot and a rollback): `Table = auto`
# alone does NOT produce that order. `ip rule add` without an explicit priority does not append to
# the end of the list — the kernel's fib_default_rule_pref() picks (priority of the SECOND existing
# rule) - 1. With Tailscale's 5210 rule already present, wg-quick's rules landed at **5208/5209,
# ahead of Tailscale's**, so `not fwmark <mark> lookup <table>` matched first and routed
# 100.100.100.100 into the tunnel. MagicDNS timed out, and with DNS dead the machine looked like it
# had no internet at all — even though the tunnel itself was fine (handshake OK, ping and curl by
# raw IP both worked).
#
# So postUp deletes the two rules wg-quick just created and re-adds them at fixed priorities. The
# selectors are unchanged; only the priority moves. wg-quick's own teardown deletes by selector
# (`ip rule delete table <n>`), not by priority, so it still cleans up correctly.
#
# Verify after any Tailscale or wg-quick bump — `ip rule show` with the tunnel up must list 5210
# and 5270 ABOVE 32764/32765, and `ip route get 100.100.100.100` must say `dev tailscale0`.
#
# IPv6: this machine has no global IPv6 of its own since it moved behind the OpenWrt router (ULA
# only, no v6 default route). Four of the five Proton servers carry IPv6 inside the tunnel, so the
# tunnel is what gives IPv6 back — and because there is no other v6 default route, v6 either goes
# through Proton or nowhere. That is leak-proof by construction. The Tor server is IPv4-only and is
# handled below.
#
# DNS is deliberately NOT taken from Proton (no `dns =` here). dnscrypt-proxy2 already encrypts
# lookups (see nixos/networking.nix) and they exit through the tunnel, so the resolver sees Proton's
# IP and Proton sees opaque DoH — neither has the whole picture. Setting Proton's DNS would add a
# third resolver manager fighting MagicDNS and dnscrypt for /etc/resolv.conf.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.suzu.system.vpn;

  # Proton hands out the same tunnel addresses no matter which exit you use.
  v4Address = "10.2.0.2/32";
  v6Address = "2a07:b944::2:2/128";

  # One private key works across Proton's whole fleet, so switching exit node means swapping only
  # these two public values. The account features (Moderate NAT, NetShield) are bound to the KEY,
  # not the server — the key in sops was generated with Moderate NAT on, which is what matters for
  # NAT traversal; NetShield is irrelevant here since Proton never sees our DNS.
  servers = {
    br-65 = {
      publicKey = "C3LgiID8tKOhXsu4Tyu8NMz5/WOWZoeZAY41Bybp5gM=";
      endpoint = "146.70.98.162:51820";
      ipv6 = true;
      desc = "BR#65 — Brazil, lowest latency";
    };
    br-82 = {
      publicKey = "uuIq8uVHFloPPDpl0dKcCiGmnSWARGpj6Wcy/XI+6z8=";
      endpoint = "146.70.98.98:51820";
      ipv6 = true;
      desc = "BR#82 — Brazil, lowest latency";
    };
    us = {
      publicKey = "E9m7utnaVJ64+Z3zKXbxfxSMZ/CpKWa8R3mDwKczF2E=";
      endpoint = "149.34.251.137:51820";
      ipv6 = true;
      desc = "US-CA#935 — California (no online-ID law, unlike most US states)";
    };
    jp = {
      publicKey = "BkgDHEcC60DJjSseQB+/IkApYytVIMYa2vcOTqde0xQ=";
      endpoint = "138.199.21.214:51820";
      ipv6 = true;
      desc = "JP#277 — Japan";
    };
    ch = {
      publicKey = "aASCj4nm+S6BGoSa+XUqk7RZBouQWjcZGnnnRucF7gw=";
      endpoint = "66.234.146.34:51820";
      ipv6 = true;
      desc = "CH#1048 — Switzerland, stronger privacy/speech law";
    };
    # IPv4-ONLY. Its config still lists ::/0 in AllowedIPs but ships no IPv6 address — installing
    # that route with no source address would hang v6 connections instead of letting them fall back
    # to v4, so IPv6 is dropped entirely for this one.
    tor = {
      publicKey = "E5JWfTrD/cRf5W4shN34r83jtyMurnv+SL+BnYOk5yA=";
      endpoint = "89.187.171.248:51820";
      ipv6 = false;
      desc = "US-GA#29 — Tor network exit";
    };
  };

  ifaceOf = name: "proton-${name}";
  unitOf = name: "wg-quick-${ifaceOf name}.service";
  # "146.70.98.162:51820" -> "146.70.98.162"; the kill switch has to let handshakes reach these.
  hostOf = s: lib.head (lib.splitString ":" s.endpoint);

  serverNames = lib.attrNames servers;

  # Escape hatch + switcher, in the same shape as companion-ctl / imagegen-ctl / rp-on.
  protonvpn-ctl = pkgs.writeShellApplication {
    name = "protonvpn-ctl";
    runtimeInputs = [
      pkgs.systemd
      pkgs.iptables
      pkgs.wireguard-tools
      pkgs.curl
    ];
    text = ''
      units=(${lib.concatStringsSep " " (map unitOf serverNames)})

      # `wg show` and `iptables -C` both need root. Run unprivileged they fail, and if that failure
      # is swallowed the status output LIES — it reported "kill switch NOT armed" while the chain
      # was in fact installed. So escalate when needed, and say "unknown" rather than guess.
      as_root() {
        if [ "$(id -u)" -eq 0 ]; then "$@"; else sudo -n "$@"; fi
      }

      stop_all() {
        for u in "''${units[@]}"; do
          systemctl is-active --quiet "$u" && systemctl stop "$u"
        done
        return 0
      }

      case "''${1:-status}" in
        ${lib.concatStringsSep "|" serverNames})
          stop_all
          # Re-arm the kill switch in case a previous `off` removed it.
          systemctl reload-or-restart firewall.service
          systemctl start "wg-quick-proton-$1.service"
          echo "Proton VPN: now exiting via '$1'."
          ;;
        off)
          stop_all
          # Without this the machine would have no internet at all: the kill switch rejects any
          # egress that isn't the tunnel, the LAN or the tailnet. Deliberately manual.
          iptables  -D OUTPUT -j proton-ks 2>/dev/null || true
          ip6tables -D OUTPUT -j proton-ks 2>/dev/null || true
          echo "Proton VPN: OFF, and the kill switch was removed — traffic is now in the clear."
          echo "Re-arm with: protonvpn-ctl <server>   (or: nixos-rebuild switch)"
          ;;
        status)
          active=""
          for n in ${lib.concatStringsSep " " serverNames}; do
            if systemctl is-active --quiet "wg-quick-proton-$n.service"; then active="$n"; fi
          done
          if [ -z "$active" ]; then
            echo "Proton VPN: OFF"
          else
            echo "Proton VPN: ON via '$active'"
            as_root wg show "proton-$active" transfer 2>/dev/null || echo "  (transfer stats need root)"
          fi
          if ! as_root true 2>/dev/null; then
            echo "Kill switch: unknown (needs root)"
          elif as_root iptables -C OUTPUT -j proton-ks 2>/dev/null; then
            echo "Kill switch: armed"
          else
            echo "Kill switch: NOT armed"
          fi
          ;;
        ip)
          # What the outside world sees. Uses a plain-HTTP-free endpoint over the tunnel.
          curl -s --max-time 10 https://api.ipify.org || echo "(no answer — tunnel down?)"
          echo
          ;;
        *)
          echo "usage: protonvpn-ctl [${lib.concatStringsSep "|" serverNames}|off|status|ip]" >&2
          exit 1
          ;;
      esac
    '';
  };
in
{
  options.suzu.system.vpn = {
    enable = lib.mkEnableOption "Proton VPN full-tunnel (WireGuard) with a fail-closed kill switch";

    server = lib.mkOption {
      type = lib.types.enum serverNames;
      default = "br";
      description = ''
        Which Proton exit node comes up at boot. Switch at runtime without a rebuild using
        `protonvpn-ctl <name>`; this option only decides the default.
      '';
    };

    killSwitch = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Reject any egress that isn't the tunnel, the LAN or the tailnet, so a tunnel that fails to
        come up leaves the machine offline rather than silently in the clear.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    sops.secrets.protonvpn_wg_key = { };

    # All five interfaces are declared; only the chosen one autostarts. The rest exist as stopped
    # units so `protonvpn-ctl <name>` is a plain `systemctl start` with nothing to generate.
    networking.wg-quick.interfaces = lib.mapAttrs' (
      name: s:
      lib.nameValuePair (ifaceOf name) {
        autostart = name == cfg.server;
        address = [ v4Address ] ++ lib.optional s.ipv6 v6Address;
        privateKeyFile = config.sops.secrets.protonvpn_wg_key.path;

        # Re-prioritise the two rules wg-quick just installed so Tailscale's (5210-5270) are
        # evaluated first. Without this the tunnel eats MagicDNS — see the header for the full
        # story. The fwmark is read back rather than hardcoded because wg-quick picks 51820 only if
        # that table is free and increments otherwise.
        postUp =
          let
            fixFamily = proto: ''
              ip ${proto} rule del not fwmark "$mark" table "$tbl" 2>/dev/null || true
              ip ${proto} rule del table main suppress_prefixlength 0 2>/dev/null || true
              ip ${proto} rule add table main suppress_prefixlength 0 priority 32764
              ip ${proto} rule add not fwmark "$mark" table "$tbl" priority 32765
            '';
          in
          ''
            mark=$(${pkgs.wireguard-tools}/bin/wg show ${ifaceOf name} fwmark)
            tbl=$((mark))
            ${fixFamily "-4"}
            ${lib.optionalString s.ipv6 (fixFamily "-6")}
            ${lib.optionalString s.ipv6 ''
              # Give the MAIN table an IPv6 default via the tunnel. Tailscale marks its own packets
              # (fwmark 0x80000) and its rule 5210 sends them to main precisely so they skip any
              # tunnel — but main has no IPv6 route at all here (this host only has a ULA since it
              # moved behind the OpenWrt router), so those packets fell through to Tailscale's own
              # `5250: unreachable` and tailscaled died with "network is unreachable" trying to
              # reach controlplane.tailscale.com over v6. It only started failing once the tunnel
              # gave the host a *global* v6 address and things began attempting v6 at all.
              #
              # No loop: the tunnel's own endpoint is IPv4. Self-cleaning: routes bound to a device
              # disappear with it, so nothing lingers if the tunnel drops.
              ip -6 route replace default dev ${ifaceOf name} table main metric 1024
            ''}
          '';
        peers = [
          {
            publicKey = s.publicKey;
            endpoint = s.endpoint;
            allowedIPs = [ "0.0.0.0/0" ] ++ lib.optional s.ipv6 "::/0";
            # Proton ships this in every config, and it matters more than usual here: yosai is
            # behind double NAT (OpenWrt + the ISP router), so without keepalive the NAT mapping
            # expires and the tunnel goes silent until we happen to send something.
            persistentKeepalive = 25;
          }
        ];
      }
    ) servers;

    environment.systemPackages = [
      protonvpn-ctl
      pkgs.wireguard-tools
    ];

    # KILL SWITCH. Lives in the firewall rather than in wg-quick's PostUp on purpose: PostUp rules
    # only exist while the interface does, and the failure that actually matters is the tunnel not
    # coming up at all (bad key, dead endpoint, boot ordering) — exactly when PostUp never runs.
    # Here the rules are present from firewall start, so "no tunnel" means "no internet", not
    # "internet in the clear".
    networking.firewall.extraCommands = lib.mkIf cfg.killSwitch (
      let
        allowV4 = lib.concatMapStringsSep "\n" (s: ''
          iptables -A proton-ks -d ${hostOf s} -p udp --dport 51820 -j RETURN
        '') (lib.attrValues servers);
      in
      ''
        # Idempotent: firewall.service re-runs this on every reload/rebuild.
        iptables -N proton-ks 2>/dev/null || iptables -F proton-ks
        iptables -A proton-ks -o lo -j RETURN
        iptables -A proton-ks -o "proton-+" -j RETURN
        iptables -A proton-ks -o tailscale0 -j RETURN
        # tailscaled marks its own outbound WireGuard packets; they leave via enp7s0, not
        # tailscale0, so without this the tunnel-bypass rules above would be undone by the firewall.
        iptables -A proton-ks -m mark --mark 0x80000/0xff0000 -j RETURN
        # All of RFC1918, not just the LAN prefix. Two reasons, both learned the hard way:
        #   - The original `192.168.0.0/24` missed the **Docker bridges** (172.17-172.20), so every
        #     host->container connection was rejected — the companion on 172.18.0.5:12393 included.
        #   - The LAN prefix itself already moved once (192.168.1.0/24 -> 192.168.0.0/24 when the
        #     Archer became the router), and a hardcoded /24 would have silently cut the LAN off.
        # Safe to allow wholesale: private ranges are not routable on the public internet, so they
        # cannot be the "leak" this kill switch exists to prevent.
        iptables -A proton-ks -d 10.0.0.0/8 -j RETURN
        iptables -A proton-ks -d 172.16.0.0/12 -j RETURN
        iptables -A proton-ks -d 192.168.0.0/16 -j RETURN
        iptables -A proton-ks -d 100.64.0.0/10 -j RETURN
        iptables -A proton-ks -d 224.0.0.0/4 -j RETURN
        # DHCP renewal — this host gets its address from the OpenWrt router, and the broadcast
        # destination is outside the LAN prefix, so it would otherwise be rejected and the lease
        # would eventually lapse.
        iptables -A proton-ks -p udp --dport 67:68 -j RETURN
        # The handshakes themselves must escape, or the tunnel could never come up.
        ${allowV4}
        iptables -A proton-ks -j REJECT --reject-with icmp-net-unreachable
        iptables -C OUTPUT -j proton-ks 2>/dev/null || iptables -I OUTPUT -j proton-ks

        ip6tables -N proton-ks 2>/dev/null || ip6tables -F proton-ks
        ip6tables -A proton-ks -o lo -j RETURN
        ip6tables -A proton-ks -o "proton-+" -j RETURN
        ip6tables -A proton-ks -o tailscale0 -j RETURN
        ip6tables -A proton-ks -m mark --mark 0x80000/0xff0000 -j RETURN
        # fc00::/7 covers both the router's ULA and Tailscale's fd7a: range, and is unroutable on
        # the public internet anyway — matching the prefix rather than the exact ULA means an
        # OpenWrt reset (which regenerates it) can't silently break local v6.
        ip6tables -A proton-ks -d fc00::/7 -j RETURN
        ip6tables -A proton-ks -d fe80::/10 -j RETURN
        ip6tables -A proton-ks -d ff00::/8 -j RETURN
        # NDP/RA is how the local v6 addresses exist at all.
        ip6tables -A proton-ks -p ipv6-icmp -j RETURN
        ip6tables -A proton-ks -j REJECT --reject-with icmp6-adm-prohibited
        ip6tables -C OUTPUT -j proton-ks 2>/dev/null || ip6tables -I OUTPUT -j proton-ks
      ''
    );

    networking.firewall.extraStopCommands = lib.mkIf cfg.killSwitch ''
      iptables -D OUTPUT -j proton-ks 2>/dev/null || true
      iptables -F proton-ks 2>/dev/null || true
      iptables -X proton-ks 2>/dev/null || true
      ip6tables -D OUTPUT -j proton-ks 2>/dev/null || true
      ip6tables -F proton-ks 2>/dev/null || true
      ip6tables -X proton-ks 2>/dev/null || true
    '';
  };
}
