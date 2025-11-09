# Configuration options for Floorp browser

{ config, inputs, pkgs, ...}:
{

imports = [ inputs.textfox.homeManagerModules.default ];

	# Setting it as default app for opening web files

	xdg.mimeApps = let
		associations = builtins.listToAttrs (map (name: {
			inherit name;
		value = let
			firefox = config.programs.firefox.package;
		in
			firefox.meta.desktopFilename;
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


	# Set Textfox theme for Floorp
/*	textfox = {
		enable = true;
		profile = "default";
		config = 
		with {

			background = {
				color = "${base00}"; # The background color of all elements
			};

			border = {
				color = "${base0F}"; # Border color when not hovered
				width = "4px"; # Width of borders
				transition = "1.0s ease"; # Color transition for borders
				radius = "3px"; # Border radius used throughout the config
			};

			tabs = {
				horizontal.enable = false; # Display horizontal tabs
				vertical.enable = true; # Display vertical tabs
				vertical.margin = "1.0rem"; # Margin used between elements in Sidebery
			};

			icons = {
				toolbar.extensions.enable = true; # Enables monochrome icons for supported extensions in the toolbar
				context.extensions.enable = true; # Enables monochrome icons for suported extensions in the context menu
				context.firefox.enable = true; # Enables icons for common context menu items
			};

			displayWindowControls = false;	# If window controls should be shown (minimize/maximize/close)
			displayNavButtons = true;	# Back and forward navigation buttons
			displayUrlbarIcons = true; # Icons inside the URL bar
			displaySidebarTools = true; # Sidebar tools button
			displayTitles = true; # Display titles (tabs, navbar, main, etc)

			font = { # Font family, size and accent color used through the app
				family = "Noto Mono";
				size = "14px";
				accent = "$base06";
			};
			newtabLogo = "   __            __  ____          \A   / /____  _  __/ /_/ __/___  _  __\A  / __/ _ \\| |/_/ __/ /_/ __ \\| |/_/\A / /_/  __/>  </ /_/ __/ /_/ />  <  \A \\__/\\___/_/|_|\\__/_/  \\____/_/|_|  ";
		};
	};*/

	programs.firefox = {
		enable = true;

		# Sets a default profile always with the same name "default"
		profiles.default = {
			isDefault = true;
			name = "Default";
			search = {
				default = "ddg";
				force = true;
				engines = {
					"google".metaData.hidden = true;
					"bing".metaData.hidden = true;
				};
			};
			# I use FF Sync, and already have my extensions/bookmarks/containers/etc set in there.
			# This includes just a couple important extensions that I would want even in a new install
			extensions = {
				force = true;
				
				packages = with pkgs.nur.repos.rycee.firefox-addons; [
					ublock-origin
					bitwarden
					darkreader
					sidebery
					firefox-color
				];
				settings."uBlock@raymondhill.net".settings = {
					selectedFilterLists = [
						"ublock-filters"
						"ublock-badware"
						"ublock-privacy"
						"ublock-unbreak"
						"ublock-quick-fixes"
					];
				};
			};
		};

		# Define some hardening policies. Set it so the policies can't be changed, except through this declarative file
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
			DisableFirefoxScreenshots = true;
			DisableFirefoxStudies = true;
			DisablePocket = true;
			DisableTelemetry = true;
			DisplayBookmarksToolbar = "never";
			DisplayMenuBar = "never";
			DontCheckDefaultBrowser = true;
			HardwareAcceleration = true;
			NoDefaultBookmarks = true;
			OfferToSaveLogins = false;
			PictureInPicture.enabled = false;
			PromptForDownloadLocation = false;
			EnableTrackingProtection = {
				Value = true;
				Locked = true;
				Cryptomining = true;
				Fingerprinting = true;
			};
			FirefoxSuggest = {
				WebSuggestions = false;
				SponsoredSuggestions = false;
				ImproveSuggest = false;
			};

			Preferences = mkLockedAttrs {
				# URLbar behavior - enables suggest searches for basic search suggestions, disables everything else
				"browser.urlbar.suggest.searches" = true;
				"browser.urlbar.shortcuts.bookmarks" = false;
				"browser.urlbar.shortcuts.history" = false;
				"browser.urlbar.shortcuts.tabs" = false;

				"browser.aboutConfig.showWarning" = false;
				"browser.tabs.warnOnClose" = false;
				"browser.tabs.hoverPreview.enabled" = true;
				"browser.tabs.loadInBackground" = true;
				"browser.warnOnQuitShortcut" = false;
				"browser.newtabpage.activity-stream.feeds.topsites" = false;
				"browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
				"browser.newtabpage.activity-stream.improvesearch.topSiteSearchShortcuts" = false;
				"browser.topsites.contile.enabled" = false;
				"privacy.resistFingerprinting" = true;
				"privacy.firstparty.isolate" = true;
				"privacy.trackingprotection.enabled" = true;
				"network.cookie.cookieBehavior" = 5;
				"dom.battery.enabled" = false;

				# Enables hardware acceleration
				"gfx.webrender.all" = true;
				"media.ffmpeg.vaapi.enabled" = true;
				"layers.acceleration.force-enabled" = true;

				# Forces dark mode wherever possible
				"ui.systemUsesDarkTheme" = true;
				"browser.in-content.dark-mode" = true;
				
				# Uses new gtk file picker
				"widget.use-xdg-desktop-portal.file-picker" = 1;

				# Security. Use new http and force https
				"network.http.http3.enabled" = true;
				"dom.security.https_only_mode" = true;
			};
		};
	};
}
