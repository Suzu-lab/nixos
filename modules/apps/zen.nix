# Configuration options for Zen Browser

{ inputs, pkgs, ...}:	{

		imports = [ inputs.zen-browser.homeModules.beta ];

		xdg.mimeApps = let
			associations = builtins.listToAttrs (map (name: {
				inherit name;
			value = let
				zen-browser = config.programs.zen-browser.package;
			in
				zen-browser.meta.desktopFilename;
			})[
				"application/x-extension-shtml"
				"application/x-extension-xhtml"
				"application/x-extension-html"
				"application/x-extension-xht"
				"application/x-extension-htm"
				"x-scheme-handler/unknown"
				"x-scheme-handler/mailto"
				"x-scheme-handler/chrome"
				"x-scheme-handler/about"
				"x-scheme-handler/https"
				"x-scheme-handler/http"
				"application/xhtml+xml"
				"application/json"
				"text/plain"
				"text/html"
			]);
		in {
			associations.added = associations;
			defaultApplications = associations;
		};

	programs.zen-browser = {
		enable = true;

		policies = let
			mkLockedAttrs = builtins.mapAttrs (_: value: {
				Value = value;
				Status = "locked";
			});

			mkExtensionSettings = builtins.mapAttrs (_: pluginId: {
				install_url = "https://addons.mozilla.org/firefox/downloads/latest/${pluginId}/latest.xpi";
				installation_mode = "force_installed";
			});
		in {
			AutofillAddressEnabled = true;
			AutofillCreditCardEnabled = false;
			DisableAppUpdate = true;
			DisableFeedbackCommands = true;
			DisablePocket = true;
			DisableTelemetry = true;
			DontCheckDefaultBrowser = true;
			OfferToSaveLogins = false;
			EnableTrackingProtection = {
				Value = true;
				Locked = true;
				Cryptomining = true;
				Fingerprinting = true;
			};
			# Defines extensions - https://github.com/0xc000022070/zen-browser-flake/issues/59#issuecomment-2964607780
			ExtensionSettings = mkExtensionSettings {
				"{762f9885-5a13-4abd-9c77-433dcd38b8fd}" = "return-youtube-dislikes";
				"{74145f27-f039-47ce-a470-a662b129930a}" = "clearurls";
				"firefox-extension@steamdb.info" = "steam-database";
				"ublock@raymondhill.net" = "ublock-origin";
			};
			Preferences = mkLockedAttrs {
				"browser.aboutConfig.showWarning" = false;
				"browser.tabs.warnOnClose" = false;
				"browser.tabs.hoverPreview.enabled" = true;
				"browser.newtabpage.activity-stream.feeds.topsites" = false;
				"browser.topsites.contile.enabled" = false;

				"privacy.resistFingerprinting" = true;
				"privacy.firstparty.isolate" = true;
				"network.cookie.cookieBehavior" = 5;
				"dom.battery.enabled" = false;

				"gfx.webrender.all" = true;
				"network.http.http3.enabled" = true;
			};
		};
	};
}
