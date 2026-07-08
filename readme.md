# yosai — a NixOS config you should not use

This is a bad setup. You shouldn't use it. No one should use it.

Still here? Fine. It's a single-machine NixOS + Home Manager flake for a host
called `yosai`, tracking `nixos-unstable`. It runs Niri (with Hyprland kept
around as a fallback) plus the Noctalia shell, and paints everything Catppuccin.

## Layout

- `flake.nix` — inputs and the `nixosSystem` for `yosai`.
- `hosts/yosai/` — machine-specific bits: `hardware-configuration.nix` and
  `configuration.nix` (which flips the module toggles for this host).
- `modules/` — one file per feature, grouped by kind:
  - `nixos/` — system services and hardware → `suzu.system.*`
  - `cli/` — terminal programs → `suzu.cli.*`
  - `programs/` — GUI programs → `suzu.programs.*`
  - `desktop/` — compositors, bar, portals, theming → `suzu.desktop.*` / `suzu.themes.*`
  - `ai/` — local LLM / diffusion stack → `suzu.ai.*` (currently off)
  - `base.nix` — the always-on foundation (boot, locale, nix settings, stateVersion)
  - `modules.nix` imports every module; `packages.nix` holds the system/user package lists
- `overlays/` — package overrides + the custom `onlyoffice-update` package.
- `pkgs/onlyoffice-update/` — a newer OnlyOffice than nixpkgs ships, with an
  `update.sh` that bumps the version + hash for you.
- `users/home.nix` — the `suzu` user and Home Manager wiring.

## The `suzu.*` options

Every feature module hides behind an enable toggle, so another machine only has
to flip the ones it wants in its own `configuration.nix`. `base.nix` is the sole
always-on module.

### `suzu.system.*` (modules/nixos)
| Option | What it does |
|---|---|
| `audio` | PipeWire (alsa / pulse / wireplumber) |
| `deepcool` | DeepCool Digital cooler display service |
| `disks` | extra HDD RAID + AI-models NVMe mounts |
| `firewall` | firewall + Discord RTC port ranges |
| `fonts` | system + Home Manager fonts (Noto / JetBrains Mono / …) |
| `gaming` | Steam, gamescope, gamemode, Lutris, Wine |
| `guiEssentials` | portals, greetd, polkit, dbus, keyring |
| `keychron` | udev rules for the Keychron K6 HE |
| `netdata` | Netdata metrics (web UI on `:19999`) |

### `suzu.cli.*` (modules/cli)
`fish`, `git`, `micro`, `mpv`, `yazi` — each just an `.enable`.

### `suzu.programs.*` (modules/programs)
`celluloid`, `chromium`, `gthumb`, `kitty`, `nemo`, `onlyoffice`, `vscodium`,
`zathura`, `zen` — each just an `.enable`.

### `suzu.desktop.*` (modules/desktop)
| Option | What it does |
|---|---|
| `hyprland` / `niri` | the two compositors (enable one) |
| `noctalia` | Noctalia shell/bar (settings live in `desktop/noctalia/noctalia-settings.nix`) |
| `desktopEntries` | custom + hidden `.desktop` entries |
| `fcitx5` | input method for dead keys / special characters |
| `xdg` | mime associations + XDG user dirs |

### `suzu.themes.catppuccin`
`enable`, plus `flavor` (latte / frappe / macchiato / mocha), `accent`, and `icons`.

### `suzu.networking`
`enable`, `doh.enable` (DNS-over-HTTPS via dnscrypt-proxy2), `doh.port`.

### `suzu.ai.*` (modules/ai — commented out in `configuration.nix`)
`ollama` (`enable`, `backend`, `models`), `webui`, `comfyui`.

## Rebuilding

```sh
sudo nixos-rebuild switch --flake .#yosai
```

## Updating OnlyOffice

```sh
./pkgs/onlyoffice-update/update.sh          # bump to the latest release
./pkgs/onlyoffice-update/update.sh 9.4.0    # pin a specific version
```

Then rebuild. More detail in `pkgs/onlyoffice-update/readme.md`.

## Adding another machine

1. Create `hosts/<name>/{hardware-configuration,configuration}.nix`.
2. In its `configuration.nix`, flip only the `suzu.*` toggles that host needs.
3. Add a `nixosConfigurations.<name>` entry in `flake.nix`.

But you won't, because — as established — you shouldn't use this config.
