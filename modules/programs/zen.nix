# Configuration options for Zen Browser
{
  config,
  inputs,
  lib,
  ...
}:
let
  cfg = config.suzu.programs.zen;
in
{
  options.suzu.programs.zen.enable = lib.mkEnableOption "Zen Browser";

  config = lib.mkIf cfg.enable {
    hm = {
      # Configuring through home-manager since the Zen flake exposes it as a HM module
      imports = [ inputs.zen-browser.homeModules.beta ];
      programs.zen-browser = {
    
        enable = true;
        setAsDefaultBrowser = true;

        policies =
        let
          mkLockedAttrs = builtins.mapAttrs (
            _: value: {
              Value = value;
              Status = "locked";
            }
          );

        in
        {
          AutofillAddressEnabled = true;
          AutofillCreditCardEnabled = false;
          DisableAppUpdate = true;
          DisableFeedbackCommands = true;
          DisablePocket = true;
          DisableTelemetry = true;
          DontCheckDefaultBrowser = true;
          NoDefaultBookmarks = true;
          OfferToSaveLogins = false;
          EnableTrackingProtection = {
            Value = true;
            Locked = true;
            Cryptomining = true;
            Fingerprinting = true;
          };
          # Installing basic extensions (Zen already has Multi-Account Containers by default)
          ExtensionSettings = {
            # uBlock Origin
            "uBlock0@raymondhill.net" = {
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
              installation_mode = "force_installed";
            };
            # Bitwarden
            "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/bitwarden-password-manager/latest.xpi";
              installation_mode = "force_installed";
            };
            # Dark Reader
            "addon@darkreader.org" = {
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/darkreader/latest.xpi";
              installation_mode = "force_installed";
            };
          };

          Preferences = mkLockedAttrs {
            
            # Browser and tab behavior
            "browser.aboutConfig.showWarning" = false;
            "browser.tabs.warnOnClose" = false;
            "browser.tabs.hoverPreview.enabled" = true;
            "browser.newtabpage.activity-stream.feeds.topsites" = false;
            "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
            "browser.newtabpage.activity-stream.improvesearch.topSiteSearchShortcuts" = false;
            "browser.topsites.contile.enabled" = false;
            "browser.tabs.loadInBackground" = true;
            "browser.warnOnQuitShortcut" = false;

            # URLbar behavior - enables suggest searches for basic search suggestions; disables everything else
            "browser.urlbar.suggest.searches" = true;
            "browser.urlbar.shortcuts.bookmarks" = false;
            "browser.urlbar.shortcuts.history" = false;
            "browser.urlbar.shortcuts.tabs" = false;

            # Makes extensions activate automatically
            "extensions.autoDisableScopes" = 0;

            # Forces dark mode in web pages
            "browser.in-content.dark-mode" = true;
            "layout.css.prefers-color-scheme.content-override" = 0;

            # Privacy settings
            "privacy.resistFingerprinting" = true;
            "privacy.firstparty.isolate" = true;
            "network.cookie.cookieBehavior" = 5;
            "dom.battery.enabled" = false;
            "dom.security.https_only_mode" = true;

            # Hardware acceleration
            "gfx.webrender.all" = true;
            "media.ffmpeg.vaapi.enabled" = true;
            "layers.acceleration.force-enabled" = true;
            "network.http.http3.enabled" = true;

            # XDG poral integration
            "widget.use-xdg-desktop-portal.file-picker" = 1;
            "widget.use-xdg-desktop-portal.settings" = 1;
          };
        };

        profiles.default = {
          settings = {
            "zen.workspaces.continue-where-left-off" = true;
            "zen.workspaces.force-container-workspace" = true;
            "zen.workspaces.hide-default-container-indicator" = false;
            "zen.workspaces.natural-scroll" = true;
            "zen.welcome-screen.seen" = true;
          };
          # Forcing Zen to use the same containers I use in Sync
          containersForce = true;
          containers = {
            Suzu = { id = 1; icon = "fingerprint"; color = "pink"; };
            Personal = { id = 2; icon = "tree"; color = "blue"; };
            Work = { id = 3; icon = "briefcase"; color = "green"; };
            Youtube = { id = 4; icon = "chill"; color = "orange"; };
            Twitch = { id = 5; icon = "fence"; color = "turquoise"; };
            Reddit = { id = 6; icon = "fence"; color = "yellow"; };
            "4chan" = { id = 7; icon = "circle"; color = "purple"; };
            "Path of Exile" = { id = 8; icon = "pet"; color = "yellow"; };
            Warframe = { id = 9; icon = "fruit"; color = "purple"; };
            Exhentai = { id = 10; icon = "fruit"; color = "red"; };
            e621 = { id = 11; icon = "pet"; color = "red"; };
            Shopping = { id = 12; icon = "cart"; color = "pink"; };
          };

          # Setting up Zen spaces
          spacesForce = true;
          spaces = {
            "Trash" = {
              id = "11111111-1111-4111-a111-111111111111"; # Arbitrary UUID just to identify the space
              position = 1000;
              icon = "chrome://browser/skin/zen-icons/selectable/grid-3x3.svg";
              # No specific container for this space
            };
            "Important" = {
              id = "22222222-2222-4222-a222-222222222222";
              position = 2000;
              icon = "chrome://browser/skin/zen-icons/selectable/code.svg";
              # No specific container for this space
            };
            "Media" = {
              id = "33333333-3333-4333-a333-333333333333";
              position = 3000;
              icon = "chrome://browser/skin/zen-icons/selectable/video.svg";
              container = 4; # Container "Youtube" always opens in this space
            };
            "Work" = {
              id = "44444444-4444-4444-a444-444444444444";
              position = 4000;
              icon = "chrome://browser/skin/zen-icons/selectable/briefcase.svg";
              container = 3; # Container "Work" always opens in this space
            };
            "Stuff" = {
              id = "55555555-5555-4555-a555-555555555555";
              position = 5000;
              icon = "chrome://browser/skin/zen-icons/selectable/star.svg";
              container = 10; # Container Exhentai always opens in this space
            };
          };
        };
      };
    };
  };
}
