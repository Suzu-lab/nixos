# Configuration options for Floorp browser

{ config, inputs, pkgs, ...}:	{

	# Setting it as default app for opening web files

	xdg.mimeApps = let
		associations = builtins.listToAttrs (map (name: {
			inherit name;
		value = let
			floorp = config.programs.zen-browser.package;
		in
			floorp.meta.desktopFilename;
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

	programs.floorp = {
		enable = true;

		policies = let
			mkLockedAttrs = builtins.mapAttrs (_: value: {
				Value = value;
				Status = "locked";
			});

		in {
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
