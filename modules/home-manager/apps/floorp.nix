# Configuration options for Floorp browser

{ config, inputs, pkgs, ...}:
{

# imports = [ inputs.textfox.homeManagerModules.default ];

	# Setting it as default app for opening web files

	xdg.mimeApps = let
		associations = builtins.listToAttrs (map (name: {
			inherit name;
		value = let
			floorp = config.programs.floorp.package;
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

		# Define some hardening policies. Set it so the policies can't be changed; except through this declarative file
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
		};
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
			# Trying to force Floorp to use only the containers I always use in my sync
			containersForce = true;
			containers = {
				suzu = {
					id = 1;
					icon = "fingerprint";
					color = "pink";
					name = "Suzu";
				};
				personal = {
					id = 2;
					icon = "tree";
					color = "blue";
					name = "Personal";
				};
				work = {
            		id = 3;
                    icon = "briefcase";
            		color = "green";
            		name = "Work";
        		};
				youtube = {
					id = 4;
					icon = "chill";
					color = "orange";
					name = "Youtube";
				};
				twitch = {
					id = 5;
					icon = "fence";
					color = "turquoise";
					name = "Twitch";
				};
				reddit = {
					id = 6;
					icon = "fence";
					color = "yellow";
					name = "Reddit";
				};
				"4chan" = {
					id = 7;
					icon = "circle";
					color = "purple";
					name = "4chan";
				};
				poe = {
					id = 8;
					icon = "pet";
					color = "yellow";
					name = "Path of Exile";
				};
				warframe = {
					id = 9;
					icon = "fruit";
					color = "purple";
					name = "Warframe";
				};
				exhentai = {
					id = 10;
					icon = "fruit";
					color = "red";
					name = "Exhentai";
				};
				e621 = {
            		id =  11;
            		icon = "pet";
            		color = "red";
            		name = "e621";
		        };
				shopping = {
					id = 12;
					icon = "cart";
					color = "pink";
					name = "Shopping";
				};
			};
			# I use FF Sync; and already have my extensions/bookmarks/containers/etc set in there.
			# This includes just a couple important extensions that I would want even in a new install
			extensions = {
				force = true;
				packages = with pkgs.nur.repos.rycee.firefox-addons; [
					ublock-origin
					bitwarden
					darkreader
					sidebery
					firefox-color
					multi-account-containers
				];
				settings."uBlock0@raymondhill.net".settings = {
					selectedFilterLists = [
						"ublock-filters"
						"ublock-badware"
						"ublock-privacy"
						"ublock-unbreak"
						"ublock-quick-fixes"
					];
				};
				settings."{3c078156-979c-498b-8990-85f7987dd929}".settings = {
					force = true;
					containers = {
						firefox-container-1 = {
							id = "firefox-container-1";
							cookieStoreId = "firefox-container-1";
							name = "Suzu";
							icon = "fingerprint";
							color = "pink";
							colorCode = "#37adff";
							proxified = false;
							proxy = null;
							reopenRulesActive = false;
							reopenRules = [];
							userAgentActive = false;
							userAgent = "";
						};
						firefox-container-2 = {
							id = "firefox-container-2";
							cookieStoreId = "firefox-container-2";
							name = "Personal";
							icon = "tree";
							color = "blue";
							colorCode = "#37adff";
							proxified = false;
							proxy = null;
							reopenRulesActive = false;
							reopenRules = [];
							userAgentActive = false;
							userAgent = "";
						};
						firefox-container-3 = {
            				id =  "firefox-container-3";
            				cookieStoreId = "firefox-container-3";
            				name = "Work";
            				icon = "briefcase";
            				color = "green";
            				colorCode = "#37adff";
            				proxified = false;
            				proxy = null;
            				reopenRulesActive = false;
            				reopenRules =  [];
            				userAgentActive = false;
            				userAgent = "";
        				};
						firefox-container-4 = {
							id = "firefox-container-4";
							cookieStoreId = "firefox-container-4";
							name = "Youtube";
							icon = "chill";
							color = "orange";
							colorCode = "#37adff";
							proxified = false;
							proxy = null;
							reopenRulesActive = false;
							reopenRules = [];
							userAgentActive = false;
							userAgent = "";
						};
						firefox-container-5 = {
							id = "firefox-container-5";
							cookieStoreId = "firefox-container-5";
							name = "Twitch";
							icon = "fence";
							color = "turquoise";
							colorCode = "#37adff";
							proxified = false;
							proxy = null;
							reopenRulesActive = false;
							reopenRules = [];
							userAgentActive = false;
							userAgent = "";
						};
						firefox-container-6 = {
							id = "firefox-container-6";
							cookieStoreId = "firefox-container-6";
							name = "Reddit";
							icon = "fence";
							color = "yellow";
							colorCode = "#37adff";
							proxified = false;
							proxy = null;
							reopenRulesActive = false;
							reopenRules = [];
							userAgentActive = false;
							userAgent = "";
						};
						firefox-container-7 = {
							id = "firefox-container-7";
							cookieStoreId = "firefox-container-7";
							name = "4chan";
							icon = "circle";
							color = "purple";
							colorCode = "#37adff";
							proxified = false;
							proxy = null;
							reopenRulesActive = false;
							reopenRules = [];
							userAgentActive = false;
							userAgent = "";
						};
						firefox-container-8 = {
							id = "firefox-container-8";
							cookieStoreId = "firefox-container-8";
							name = "Path of Exile";
							icon = "pet";
							color = "yellow";
							colorCode = "#37adff";
							proxified = false;
							proxy = null;
							reopenRulesActive = false;
							reopenRules = [];
							userAgentActive = false;
							userAgent = "";
						};
						firefox-container-9 = {
							id = "firefox-container-9";
							cookieStoreId = "firefox-container-9";
							name = "Warframe";
							icon = "fruit";
							color = "purple";
							colorCode = "#37adff";
							proxified = false;
							proxy = null;
							reopenRulesActive = false;
							reopenRules = [];
							userAgentActive = false;
							userAgent = "";
						};
						firefox-container-10 = {
							id = "firefox-container-10";
							cookieStoreId = "firefox-container-10";
							name = "Exhentai";
							icon = "fruit";
							color = "red";
							colorCode = "#37adff";
							proxified = false;
							proxy = null;
							reopenRulesActive = false;
							reopenRules = [];
							userAgentActive = false;
							userAgent = "";
						};
						firefox-container-11 = {
							id = "firefox-container-11";
							cookieStoreId = "firefox-container-11";
							name = "e621";
							icon = "pet";
							color = "red";
							colorCode = "#37adff";
							proxified = false;
							proxy = null;
							reopenRulesActive = false;
							reopenRules = [];
							userAgentActive = false;
							userAgent = "";
						};
						firefox-container-12 = {
							id = "firefox-container-12";
							cookieStoreId = "firefox-container-12";
							name = "Shopping";
							icon = "cart";
							color = "pink";
							colorCode = "#37adff";
							proxified = false;
							proxy = null;
							reopenRulesActive = false;
							reopenRules = [];
							userAgentActive = false;
							userAgent = "";
						};
						firefox-container-13 = {
							id = "firefox-container-13";
							cookieStoreId = "firefox-container-13";
							name = "Private Container";
							icon = "chill";
							color = "purple";
							colorCode = "#37adff";
							proxified = false;
							proxy = null;
							reopenRulesActive = false;
							reopenRules = [];
							userAgentActive = false;
							userAgent = "";
						};
					};
					settings = {
						nativeScrollbars = true;
						nativeScrollbarsThin = true;
						nativeScrollbarsLeft = true;
						selWinScreenshots = false;
						updateSidebarTitle = true;
						markWindow = false;
						markWindowPreface = "[Sidebery] ";
						ctxMenuNative = true;
						ctxMenuRenderInact = true;
						ctxMenuRenderIcons = true;
						ctxMenuIgnoreContainers = "";
						navBarLayout = "horizontal";
						navBarInline = true;
						navBarSide = "left";
						hideAddBtn = false;
						hideSettingsBtn = false;
						navBtnCount = true;
						hideEmptyPanels = true;
						hideDiscardedTabPanels = false;
						navActTabsPanelLeftClickAction = "none";
						navActBookmarksPanelLeftClickAction = "none";
						navTabsPanelMidClickAction = "discard";
						navBookmarksPanelMidClickAction = "none";
						navSwitchPanelsWheel = true;
						subPanelRecentlyClosedBar = true;
						subPanelBookmarks = false;
						subPanelHistory = false;
						subPanelSync = false;
						groupLayout = "list";
						containersSortByName = false;
						skipEmptyPanels = false;
						dndTabAct = true;
						dndTabActDelay = 750;
						dndTabActMod = "none";
						dndExp = "pointer";
						dndExpDelay = 750;
						dndExpMod = "none";
						dndOutside = "win";
						dndActTabFromLink = true;
						dndActSearchTab = true;
						dndMoveTabs = false;
						dndMoveBookmarks = false;
						searchBarMode = "dynamic";
						searchPanelSwitch = "same_type";
						searchBookmarksShortcut = "";
						searchHistoryShortcut = "";
						warnOnMultiTabClose = "collapsed";
						activateLastTabOnPanelSwitching = true;
						activateLastTabOnPanelSwitchingLoadedOnly = true;
						switchPanelAfterSwitchingTab = "always";
						tabRmBtn = "hover";
						activateAfterClosing = "prev_act";
						activateAfterClosingStayInPanel = true;
						activateAfterClosingGlobal = false;
						activateAfterClosingNoFolded = true;
						activateAfterClosingNoDiscarded = true;
						askNewBookmarkPlace = true;
						tabsRmUndoNote = true;
						tabsUnreadMark = true;
						tabsUpdateMark = "all";
						tabsUpdateMarkFirst = true;
						tabsReloadLimit = 5;
						tabsReloadLimitNotif = true;
						showNewTabBtns = true;
						newTabBarPosition = "after_tabs";
						tabsPanelSwitchActMove = true;
						tabsPanelSwitchActMoveAuto = true;
						tabsUrlInTooltip = "full";
						newTabCtxReopen = true;
						tabWarmupOnHover = true;
						tabSwitchDelay = 0;
						forceDiscard = true;
						moveNewTabPin = "start";
						moveNewTabParent = "last_child";
						moveNewTabParentActPanel = true;
						moveNewTab = "end";
						moveNewTabActivePin = "end";
						pinnedTabsPosition = "top";
						pinnedTabsList = false;
						pinnedAutoGroup = true;
						pinnedNoUnload = false;
						pinnedForcedDiscard = false;
						tabsTree = true;
						groupOnOpen = true;
						tabsTreeLimit = "none";
						autoFoldTabs = false;
						autoFoldTabsExcept = "none";
						autoExpandTabs = false;
						autoExpandTabsOnNew = false;
						rmChildTabs = "folded";
						tabsLvlDots = true;
						discardFolded = false;
						discardFoldedDelay = 0;
						discardFoldedDelayUnit = "sec";
						tabsTreeBookmarks = true;
						treeRmOutdent = "branch";
						autoGroupOnClose = true;
						autoGroupOnClose0Lvl = false;
						autoGroupOnCloseMouseOnly = false;
						ignoreFoldedParent = false;
						showNewGroupConf = true;
						sortGroupsFirst = true;
						colorizeTabs = true;
						colorizeTabsSrc = "domain";
						colorizeTabsBranches = true;
						colorizeTabsBranchesSrc = "url";
						inheritCustomColor = true;
						previewTabs = true;
						previewTabsMode = "p";
						previewTabsPageModeFallback = "i";
						previewTabsInlineHeight = 70;
						previewTabsPopupWidth = 280;
						previewTabsTitle = 2;
						previewTabsUrl = 1;
						previewTabsSide = "right";
						previewTabsDelay = 500;
						previewTabsFollowMouse = true;
						previewTabsWinOffsetY = 36;
						previewTabsWinOffsetX = 6;
						previewTabsInPageOffsetY = 0;
						previewTabsInPageOffsetX = 0;
						previewTabsCropRight = 0;
						hideInact = false;
						hideFoldedTabs = false;
						hideFoldedParent = "none";
						nativeHighlight = false;
						warnOnMultiBookmarkDelete = "collapsed";
						autoCloseBookmarks = false;
						autoRemoveOther = false;
						highlightOpenBookmarks = false;
						activateOpenBookmarkTab = false;
						showBookmarkLen = true;
						bookmarksRmUndoNote = true;
						loadBookmarksOnDemand = true;
						pinOpenedBookmarksFolder = true;
						oldBookmarksAfterSave = "ask";
						loadHistoryOnDemand = true;
						fontSize = "xs";
						animations = true;
						animationSpeed = "norm";
						theme = "proton";
						density = "compact";
						colorScheme = "ff";
						snapNotify = true;
						snapExcludePrivate = true;
						snapInterval = 0;
						snapIntervalUnit = "min";
						snapLimit = 0;
						snapLimitUnit = "snap";
						snapAutoExport = false;
						snapAutoExportType = "json";
						snapAutoExportPath = "Sidebery/snapshot-%Y.%M.%D-%h.%m.%s";
						snapMdFullTree = true;
						hScrollAction = "switch_panels";
						onePanelSwitchPerScroll = false;
						wheelAccumulationX = true;
						wheelAccumulationY = true;
						navSwitchPanelsDelay = 128;
						scrollThroughTabs = "none";
						scrollThroughVisibleTabs = true;
						scrollThroughTabsSkipDiscarded = true;
						scrollThroughTabsExceptOverflow = true;
						scrollThroughTabsCyclic = false;
						scrollThroughTabsScrollArea = 0;
						autoMenuMultiSel = true;
						multipleMiddleClose = true;
						longClickDelay = 500;
						wheelThreshold = false;
						wheelThresholdX = 10;
						wheelThresholdY = 60;
						tabDoubleClick = "new_after";
						tabsSecondClickActPrev = false;
						tabsSecondClickActPrevPanelOnly = false;
						tabsSecondClickActPrevNoUnload = false;
						shiftSelAct = true;
						activateOnMouseUp = false;
						tabLongLeftClick = "none";
						tabLongRightClick = "none";
						tabMiddleClick = "close";
						tabPinnedMiddleClick = "discard";
						tabMiddleClickCtrl = "discard";
						tabMiddleClickShift = "duplicate";
						tabCloseMiddleClick = "close";
						tabsPanelLeftClickAction = "none";
						tabsPanelDoubleClickAction = "tab";
						tabsPanelRightClickAction = "menu";
						tabsPanelMiddleClickAction = "tab";
						newTabMiddleClickAction = "new_child";
						bookmarksLeftClickAction = "open_in_act";
						bookmarksLeftClickActivate = false;
						bookmarksLeftClickPos = "default";
						bookmarksMidClickAction = "open_in_new";
						bookmarksMidClickActivate = false;
						bookmarksMidClickRemove = false;
						bookmarksMidClickPos = "default";
						historyLeftClickAction = "open_in_act";
						historyLeftClickActivate = false;
						historyLeftClickPos = "default";
						historyMidClickAction = "open_in_new";
						historyMidClickActivate = false;
						historyMidClickPos = "default";
						syncName = "Floorp";
						syncUseFirefox = true;
						syncUseGoogleDrive = false;
						syncUseGoogleDriveApi = false;
						syncUseGoogleDriveApiClientId = "";
						syncSaveSettings = true;
						syncSaveCtxMenu = true;
						syncSaveStyles = true;
						syncSaveKeybindings = true;
						selectActiveTabFirst = true;
						selectCyclic = false;
					};
					sidebar = {
						nav = [
							"I0IUJqs4JqAH"
							"JAfMLw7MGenD"
							"vsLO2CKR4Uq0"
							"CgMJNM-E108M"
							"00zoX6YzLcZC"
							"K5i37djXCnYM"
							"y2i7iyA1y7q0"
							"sp-0"
							"remute_audio_tabs"
							"settings"
						];
						panels = {
							I0IUJqs4JqAH = {
								type = 2;
								id = "I0IUJqs4JqAH";
								name = "Trash";
								color = "toolbar";
								iconSVG = "icon_tabs";
								iconIMGSrc = "";
								iconIMG = "";
								lockedPanel = false;
								skipOnSwitching = false;
								noEmpty = false;
								newTabCtx = "none";
								dropTabCtx = "none";
								moveRules = [];
								moveExcludedTo = -1;
								bookmarksFolderId = -1;
								newTabBtns = [];
								srcPanelConfig = null;
							};
							JAfMLw7MGenD = {
								type = 2;
								id = "JAfMLw7MGenD";
								name = "Important";
								color = "purple";
								iconSVG = "icon_tabs";
								iconIMGSrc = "";
								iconIMG = "";
								lockedPanel = false;
								skipOnSwitching = false;
								noEmpty = false;
								newTabCtx = "none";
								dropTabCtx = "none";
								moveRules = [];
								moveExcludedTo = -1;
								bookmarksFolderId = -1;
								newTabBtns = [];
								srcPanelConfig = null;
							};
							vsLO2CKR4Uq0 = {
								type = 2;
								id = "vsLO2CKR4Uq0";
								name = "Projects";
								color = "blue";
								iconSVG = "icon_code";
								iconIMGSrc = "";
								iconIMG = "";
								lockedPanel = false;
								skipOnSwitching = false;
								noEmpty = false;
								newTabCtx = "none";
								dropTabCtx = "none";
								moveRules = [];
								moveExcludedTo = -1;
								bookmarksFolderId = -1;
								newTabBtns = [];
								srcPanelConfig = null;
							};
							"00zoX6YzLcZC" = {
								type = 2;
								id = "00zoX6YzLcZC";
								name = "Media";
								color = "orange";
								iconSVG = "icon_play";
								iconIMGSrc = "";
								iconIMG = "";
								lockedPanel = false;
								skipOnSwitching = false;
								noEmpty = false;
								newTabCtx = "firefox-container-4";
								dropTabCtx = "none";
								moveRules = [
									{
										id = "Qz7Xr0PUATXM";
										active = true;
										containerId = "firefox-container-4";
									}
									{
										id = "YkxosuxpmZXM";
										active = true;
										url = "\"twitch.com\"";
									}
								];
								moveExcludedTo = -1;
								bookmarksFolderId = -1;
								newTabBtns = [];
								srcPanelConfig = null;
							};
							K5i37djXCnYM = {
								type = 2;
								id = "K5i37djXCnYM";
								name = "Stuff";
								color = "pink";
								iconSVG = "fruit";
								iconIMGSrc = "";
								iconIMG = "";
								lockedPanel = true;
								skipOnSwitching = false;
								noEmpty = false;
								newTabCtx = "firefox-container-13";
								dropTabCtx = "firefox-container-13";
								moveRules = [
									{
										id = "iP2OcaA1AzYM";
										active = true;
										containerId = "firefox-container-11";
									}
									{
										id = "YXwYyKYREBYM";
										active = true;
										containerId = "firefox-container-10";
									}
									{
										id = "Wenu4CUBKZ0M";
										active = true;
										containerId = "firefox-container-13";
									}
								];
								moveExcludedTo = -1;
								bookmarksFolderId = -1;
								newTabBtns = [];
								srcPanelConfig = null;
							};
							y2i7iyA1y7q0 = {
								type = 2;
								id = "y2i7iyA1y7q0";
								name = "Work";
								color = "green";
								iconSVG = "briefcase";
								iconIMGSrc = "";
								iconIMG = "";
								lockedPanel = true;
								skipOnSwitching = false;
								noEmpty = false;
								newTabCtx = "firefox-container-3";
								dropTabCtx = "firefox-container-3";
								moveRules = [
									{
										id = "DKK7WvfNJdXM";
										active = true;
										containerId = "firefox-container-3";
									}
								];
								moveExcludedTo = -1;
								bookmarksFolderId = -1;
								newTabBtns = [];
								srcPanelConfig = null;
							};
							CgMJNM-E108M = {
								type = 2;
								id = "CgMJNM-E108M";
								name = "Search";
								color = "red";
								iconSVG = "icon_search";
								iconIMGSrc = "";
								iconIMG = "";
								lockedPanel = true;
								skipOnSwitching = false;
								noEmpty = false;
								newTabCtx = "none";
								dropTabCtx = "none";
								moveRules = [];
								moveExcludedTo = -1;
								bookmarksFolderId = -1;
								newTabBtns = [];
								srcPanelConfig = null;
							};
						};
					};
					contextMenu = {
						tabs = [
							{
								opts = [
									"undoRmTab"
									"mute"
									"reload"
									"bookmark"
								];
							}
							"separator-1"
							{
								name = "%menu.tab.move_to_sub_menu_name";
								opts = [
									"moveToNewWin"
									"moveToWin"
									"separator-5"
									"moveToPanel"
									"moveToNewPanel"
								];
							}
							{
								name = "%menu.tab.reopen_in_sub_menu_name";
								opts = [
									"reopenInNewWin"
									"reopenInWin"
									"reopenInCtr"
									"reopenInNewCtr"
								];
							}
							{
								name = "%menu.tab.colorize_";
								opts = [
									"colorizeTab"
								];
							}
							"separator-2"
							"pin"
							"duplicate"
							"discard"
							"copyTabsUrls"
							"copyTabsTitles"
							"editTabTitle"
							"separator-3"
							"group"
							"flatten"
							"separator-4"
							"urlConf"
							"clearCookies"
							"close"
						];
						tabsPanel = [
							{
								opts = [
									"undoRmTab"
									"muteAllAudibleTabs"
									"reloadTabs"
									"discardTabs"
								];
							}
							"separator-7"
							"selectAllTabs"
							"collapseInactiveBranches"
							"closeTabsDuplicates"
							"closeTabs"
							"separator-8"
							"bookmarkTabsPanel"
							"restoreFromBookmarks"
							"convertToBookmarksPanel"
							"separator-9"
							"openPanelConfig"
							"hidePanel"
							"removePanel"
						];
						bookmarks = [
							{
								name = "%menu.bookmark.open_in_sub_menu_name";
								opts = [
									"openInNewWin"
									"openInNewPrivWin"
									"separator-9"
									"openInPanel"
									"openInNewPanel"
									"separator-10"
									"openInCtr"
								];
							}
							{
								name = "%menu.bookmark.sort_sub_menu_name";
								opts = [
									"sortByNameAscending"
									"sortByNameDescending"
									"sortByLinkAscending"
									"sortByLinkDescending"
									"sortByTimeAscending"
									"sortByTimeDescending"
								];
							}
							"separator-5"
							"createBookmark"
							"createFolder"
							"createSeparator"
							"separator-8"
							"openAsBookmarksPanel"
							"openAsTabsPanel"
							"separator-7"
							"copyBookmarksUrls"
							"copyBookmarksTitles"
							"moveBookmarksTo"
							"edit"
							"delete"
						];
						bookmarksPanel = [
							"collapseAllFolders"
							"switchViewMode"
							"convertToTabsPanel"
							"separator-9"
							"unloadPanelType"
							"openPanelConfig"
							"hidePanel"
							"removePanel"
						];
					};
				};
			};

			# Defines customized settings
			settings = {
				"browser.aboutConfig.showWarning" = false;
				"browser.bookmarks.restore_default_bookmars" = false;
				# Set dark mode for sites that support it
				"browser.in-content.dark-mode" = true;
				# Removes crap from the start page
				"browser.newtabpage.activity-stream.feeds.topsites" = false;
				"browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
				"browser.newtabpage.activity-stream.improvesearch.topSiteSearchShortcuts" = false;
				"browser.proton.toolbar.version" = 3;
				# Browser tab behavior
				"browser.tabs.warnOnClose" = false;
				"browser.tabs.hoverPreview.enabled" = true;
				"browser.tabs.loadInBackground" = true;
				"browser.warnOnQuitShortcut" = false;
				# Theme config
				"browser.theme.content-theme" = 0;
				"browser.theme.toolbar-theme" = 0;
				# Hide bookmarks toolbar since the beginning
				"browser.toolbars.bookmarks.visibility" = "never";
				"browser.topsites.contile.enabled" = false;
				# URLbar behavior - enables suggest searches for basic search suggestions; disables everything else
				"browser.urlbar.suggest.searches" = true;
				"browser.urlbar.shortcuts.bookmarks" = false;
				"browser.urlbar.shortcuts.history" = false;
				"browser.urlbar.shortcuts.tabs" = false;
				"dom.battery.enabled" = false;
				# Force HTTPS and use new HTTP
				"dom.security.https_only_mode" = true;
				"network.http.http3.enabled" = true;
				# Make extensions activate automatically
				"extensions.autoDisableScopes" = 0;
				# Settings specific to Floorp
				"floorp.browser.splitView.working" = false;
				"floorp.chrome.theme.mode" = 1;
				"floorp.delete.browser.border" = true;
				# Toolbar icons config
				"browser.uiCustomization.state" = "{\"placements\":{\"widget-overflow-fixed-list\":[],\"unified-extensions-area\":[\"addon_darkreader_org-browser-action\",\"_446900e4-71c2-419f-a6a7-df9c091e268b_-browser-action\",\"firefoxcolor_mozilla_com-browser-action\"],\"nav-bar\":[\"sidebar-button\",\"back-button\",\"forward-button\",\"stop-reload-button\",\"undo-closed-tab\",\"customizableui-special-spring1\",\"vertical-spacer\",\"urlbar-container\",\"customizableui-special-spring2\",\"downloads-button\",\"fxa-toolbar-menu-button\",\"unified-extensions-button\",\"ublock0_raymondhill_net-browser-action\",\"profile-manager-button\",\"_3c078156-979c-498b-8990-85f7987dd929_-browser-action\"],\"toolbar-menubar\":[\"menubar-items\"],\"TabsToolbar\":[\"workspaces-toolbar-button\",\"firefox-view-button\",\"tabbrowser-tabs\",\"new-tab-button\",\"alltabs-button\"],\"vertical-tabs\":[],\"PersonalToolbar\":[\"import-button\",\"personal-bookmarks\"],\"nora-statusbar\":[\"screenshot-button\",\"fullscreen-button\",\"status-text\"]},\"seen\":[\"undo-closed-tab\",\"developer-button\",\"workspaces-toolbar-button\",\"ublock0_raymondhill_net-browser-action\",\"addon_darkreader_org-browser-action\",\"_446900e4-71c2-419f-a6a7-df9c091e268b_-browser-action\",\"profile-manager-button\",\"firefoxcolor_mozilla_com-browser-action\",\"_3c078156-979c-498b-8990-85f7987dd929_-browser-action\"],\"dirtyAreaCache\":[\"nav-bar\",\"vertical-tabs\",\"nora-statusbar\",\"TabsToolbar\",\"PersonalToolbar\",\"unified-extensions-area\",\"toolbar-menubar\"],\"currentVersion\":23,\"newElementCount\":4}";
				# Set UI customizations on Floorp
				"floorp.design.configs" = "{\"globalConfigs\":{\"userInterface\":\"photon\",\"faviconColor\":false,\"appliedUserJs\":\"\"},\"tabbar\":{\"tabbarStyle\":\"horizontal\",\"tabbarPosition\":\"default\",\"multiRowTabBar\":{\"maxRowEnabled\":false,\"maxRow\":3}},\"tab\":{\"tabScroll\":{\"enabled\":false,\"reverse\":false,\"wrap\":false},\"tabMinHeight\":30,\"tabMinWidth\":76,\"tabPinTitle\":false,\"tabDubleClickToClose\":false,\"tabOpenPosition\":-1},\"uiCustomization\":{\"navbar\":{\"position\":\"top\",\"searchBarTop\":false},\"display\":{\"disableFullscreenNotification\":false,\"deleteBrowserBorder\":false},\"special\":{\"optimizeForTreeStyleTab\":true,\"hideForwardBackwardButton\":false,\"stgLikeWorkspaces\":false},\"multirowTab\":{\"newtabInsideEnabled\":false},\"bookmarkBar\":{\"focusExpand\":false},\"qrCode\":{\"disableButton\":false}}}";
				# Customization for the right side panel (shortcuts for tools)
				"floorp.panelSidebar.config" = "{\"autoUnload\":false,\"position_start\":true,\"globalWidth\":400,\"displayed\":true,\"webExtensionRunningEnabled\":false}";
				"floorp.panelSidebar.data" = "{\"data\":[{\"type\":\"extension\",\"id\":\"7189d18c-99de-4cd9-a50e-2532345a1ebb\",\"width\":450,\"extensionId\":\"{446900e4-71c2-419f-a6a7-df9c091e268b}\"},{\"id\":\"default-panel-bookmarks\",\"type\":\"static\",\"width\":0,\"url\":\"floorp//bookmarks\"},{\"id\":\"default-panel-history\",\"type\":\"static\",\"width\":0,\"url\":\"floorp//history\"},{\"id\":\"default-panel-downloads\",\"type\":\"static\",\"width\":0,\"url\":\"floorp//downloads\"},{\"id\":\"default-panel-notes\",\"type\":\"static\",\"width\":0,\"url\":\"floorp//notes\"},{\"id\":\"default-panel-translate-google-com\",\"type\":\"web\",\"width\":0,\"url\":\"https://translate.google.com\",\"userContextId\":null,\"zoomLevel\":null},{\"type\":\"web\",\"id\":\"bce09ac5-98e6-4837-86fd-edf3dd66e2c3\",\"width\":450,\"url\":\"https://gemini.google.com\",\"userContextId\":21,\"userAgent\":false}]}";
				"floorp.panelSidebar.enabled" = true;
				# Hide left sidebar (Sidebery is used in its place)
				"sidebar.visibility" = "hide-sidebar";
				# user.js (experimental; still seeing exactly what it does)
				"floorp.user.js.customize" = "Fastfox";
				
				# Some privacy hardening
				"privacy.resistFingerprinting" = true;
				"privacy.firstparty.isolate" = true;
				"privacy.trackingprotection.enabled" = true;
				"network.cookie.cookieBehavior" = 1;
				
				# Enables hardware acceleration
				"gfx.webrender.all" = true;
				"media.ffmpeg.vaapi.enabled" = true;
				"layers.acceleration.force-enabled" = true;

				# CSS Style customization (hiding unwanted bars) - Floorp specific settings
				"ui.systemUsesDarkTheme" = true;
				"userChrome.autohide.back_button" = true;
				"userChrome.autohide.forward_button" = true;
				"userChrome.autohide.navbar" = false;
				"userChrome.autohide.page_action" = false;
				"userChrome.autohide.sidebar" = false;
				"userChrome.autohide.tab" = false;
				"userChrome.centered.bookmarkbar" = false;
				"userChrome.centered.tab" = false;
				"userChrome.centered.urlbar" = true;
				"userChrome.hidden.bookmarkbar_icon" = false;
				"userChrome.hidden.bookmarkbar_label" = false;
				"userChrome.hidden.disabled_menu" = false;
				"userChrome.hidden.navbar" = false;
				"userChrome.hidden.sidebar_header" = true;
				"userChrome.hidden.tab_icon" = false;
				"userChrome.hidden.tabbar" = true;
				"userChrome.hidden.urlbar_iconbox" = false;
				"userChrome.icon.disabled" = false;
				"userChrome.sidebar.overlap" = false;
				"userChrome.tabbar.as_titlebar" = false;
				"userChrome.tabbar.one_liner" = false;
				"userChrome.urlView.always_show_page_actions" = false;
				"userChrome.urlView.go_button_when_typing" = false;
				"userChrome.urlView.move_icon_to_left" = false;

				# Uses new gtk file picker
				"widget.use-xdg-desktop-portal.file-picker" = 1;				
			};
		};
	};
}
