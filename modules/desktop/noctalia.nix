# Declarative configuration for Noctalia-shell
{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.suzu.desktop.noctalia;
in
{
  options.suzu.desktop.noctalia = {
    enable = lib.mkEnableOption "Noctalia Shell";
  };

  config = lib.mkIf cfg.enable {

    environment.systemPackages = with pkgs; [
      inputs.noctalia-shell.packages.${stdenv.hostPlatform.system}.default
    ];

    hm = {
      imports = [
        inputs.noctalia-shell.homeModules.default
      ];
      programs.noctalia-shell = {
        enable = true;
        systemd.enable = true; # Autostarts the shell as a systemd service.
        settings = {
          setupCompleted = true;
          bar = {
            position = "top";
            monitors = [
              "DP-1"
            ];
            density = "comfortable";
            showOutline = false;
            showCapsule = false;
            capsuleOpacity = 0.75;
            backgroundOpacity = 0;
            useSeparateOpacity = false;
            floating = true;
            marginVertical = 4;
            marginHorizontal = 5;
            outerCorners = false;
            exclusive = true;
            hideOnOverview = false;
            widgets = {
              left = [
                {
                  colorizeDistroLogo = true;
                  colorizeSystemIcon = "none";
                  customIconPath = "";
                  enableColorization = false;
                  icon = "noctalia";
                  id = "ControlCenter";
                  useDistroLogo = true;
                }
                {
                  compactMode = true;
                  diskPath = "/";
                  id = "SystemMonitor";
                  showCpuTemp = true;
                  showCpuUsage = true;
                  showDiskUsage = false;
                  showGpuTemp = false;
                  showLoadAverage = false;
                  showMemoryAsPercent = true;
                  showMemoryUsage = true;
                  showNetworkStats = true;
                  showSwapUsage = false;
                  useMonospaceFont = true;
                  usePrimaryColor = false;
                }
                {
                  defaultSettings = {
                    arrowType = "caret";
                    byteThresholdActive = 1024;
                    fontSizeModifier = 1;
                    forceMegabytes = false;
                    iconSizeModifier = 1;
                    minWidth = 0;
                    showNumbers = true;
                    spacingInbetween = 0;
                    useCustomColors = false;
                  };
                  id = "plugin:network-indicator";
                }
                {
                  colorizeIcons = true;
                  hideMode = "hidden";
                  id = "ActiveWindow";
                  maxWidth = 145;
                  scrollingMode = "hover";
                  showIcon = true;
                  useFixedWidth = false;
                }
                {
                  compactMode = false;
                  compactShowAlbumArt = true;
                  compactShowVisualizer = false;
                  hideMode = "hidden";
                  hideWhenIdle = false;
                  id = "MediaMini";
                  maxWidth = 145;
                  panelShowAlbumArt = true;
                  panelShowVisualizer = true;
                  scrollingMode = "hover";
                  showAlbumArt = false;
                  showArtistFirst = true;
                  showProgressRing = true;
                  showVisualizer = true;
                  useFixedWidth = false;
                  visualizerType = "wave";
                }
                {
                  defaultSettings = {
                    autoStartBreaks = false;
                    autoStartWork = false;
                    compactMode = false;
                    longBreakDuration = 15;
                    sessionsBeforeLongBreak = 4;
                    shortBreakDuration = 5;
                    workDuration = 25;
                  };
                  id = "plugin:pomodoro";
                }
              ];
              center = [
                {
                  characterCount = 2;
                  colorizeIcons = true;
                  enableScrollWheel = true;
                  followFocusedScreen = false;
                  groupedBorderOpacity = 1;
                  hideUnoccupied = true;
                  iconScale = 0.8;
                  id = "Workspace";
                  labelMode = "none";
                  showApplications = true;
                  showLabelsOnlyWhenOccupied = true;
                  unfocusedIconsOpacity = 1;
                }
              ];
              right = [
                {
                  blacklist = [];
                  colorizeIcons = true;
                  drawerEnabled = true;
                  hidePassive = true;
                  id = "Tray";
                  pinned = [];
                }
                {
                  id = "plugin:clipper";
                }
                {
                  hideWhenZero = true;
                  hideWhenZeroUnread = false;
                  id = "NotificationHistory";
                  showUnreadBadge = true;
                }
                {
                  displayMode = "onhover";
                  id = "Volume";
                  middleClickCommand = "pwvucontrol || pavucontrol";
                }
                {
                  id = "plugin:simple-notes";
                }
                {
                  id = "plugin:todo";
                }
                {
                  customFont = "";
                  formatHorizontal = "HH:mm ddd, MMM dd";
                  formatVertical = "HH mm - dd MM";
                  id = "Clock";
                  tooltipFormat = "HH:mm ddd, MMM dd";
                  useCustomFont = false;
                  usePrimaryColor = true;
                }
                {
                  id = "plugin:screen-recorder";
                }
              ];
            };
            screenOverrides = [];
          };
          general = {
            avatarImage = "~/Pictures/Profile Pics/Cereal Experiments Lain.png";
            dimmerOpacity = 0.2;
            showScreenCorners = true;
            forceBlackScreenCorners = false;
            scaleRatio = 1;
            radiusRatio = 0.5;
            iRadiusRatio = 0.5;
            boxRadiusRatio = 1;
            screenRadiusRatio = 1;
            animationSpeed = 1;
            animationDisabled = false;
            compactLockScreen = false;
            lockOnSuspend = true;
            showSessionButtonsOnLockScreen = true;
            showHibernateOnLockScreen = false;
            enableShadows = false;
            shadowDirection = "bottom_right";
            shadowOffsetX = 2;
            shadowOffsetY = 3;
            language = "en";
            allowPanelsOnScreenWithoutBar = true;
            showChangelogOnStartup = true;
            telemetryEnabled = true;
            enableLockScreenCountdown = true;
            lockScreenCountdownDuration = 10000;
          };
          ui = {
            fontDefault = "Noto Sans";
            fontFixed = "Noto Sans Mono";
            fontDefaultScale = 1.1;
            fontFixedScale = 1.1;
            tooltipsEnabled = true;
            panelBackgroundOpacity = 0.76;
            panelsAttachedToBar = true;
            settingsPanelMode = "window";
            wifiDetailsViewMode = "grid";
            bluetoothDetailsViewMode = "grid";
            networkPanelView = "wifi";
            bluetoothHideUnnamedDevices = false;
            boxBorderEnabled = true;
          };
          location = {
            name = "Porto Alegre/RS";
            weatherEnabled = true;
            weatherShowEffects = true;
            useFahrenheit = false;
            use12hourFormat = false;
            showWeekNumberInCalendar = false;
            showCalendarEvents = true;
            showCalendarWeather = true;
            analogClockInCalendar = false;
            firstDayOfWeek = "unknown character to parse: -";
            ",
            " = "unknown character to parse: h";
            deWeatherTimezone = false;
            hideWeatherCityName = false;
          };
          calendar = {
            cards = [
              {
                enabled = true;
                id = "calendar-header-card";
              }
              {
                enabled = true;
                id = "calendar-month-card";
              }
              {
                enabled = true;
                id = "weather-card";
              }
            ];
          };
          wallpaper = {
            enabled = true;
            overviewEnabled = true;
            directory = "/home/suzu/Wallpapers";
            monitorDirectories = [
              {
                directory = "/home/suzu/Wallpapers/Landscape";
                name = "DP-1";
                wallpaper = "";
              }
              {
                directory = "/home/suzu/Wallpapers/Portrait";
                name = "DP-2";
                wallpaper = "";
              }
              {
                directory = "/home/suzu/Wallpapers/Landscape";
                name = "HDMI-A-1";
                wallpaper = "";
              }
              {
                directory = "/home/suzu/Wallpapers/Portrait";
                name = "DP-3";
                wallpaper = "";
              }
            ];
            enableMultiMonitorDirectories = true;
            showHiddenFiles = false;
            viewMode = "single";
            setWallpaperOnAllMonitors = true;
            fillMode = "crop";
            fillColor = "#000000";
            useSolidColor = false;
            solidColor = "#1a1a2e";
            automationEnabled = true;
            wallpaperChangeMode = "random";
            randomIntervalSec = 600;
            transitionDuration = 1500;
            transitionType = "random";
            transitionEdgeSmoothness = 5.0e-2;
            panelPosition = "follow_bar";
            hideWallpaperFilenames = false;
            useWallhaven = false;
            wallhavenQuery = "";
            wallhavenSorting = "relevance";
            wallhavenOrder = "desc";
            wallhavenCategories = "111";
            wallhavenPurity = "100";
            wallhavenRatios = "";
            wallhavenApiKey = "";
            wallhavenResolutionMode = "atleast";
            wallhavenResolutionWidth = "";
            wallhavenResolutionHeight = "";
          };
          appLauncher = {
            enableClipboardHistory = false;
            autoPasteClipboard = false;
            enableClipPreview = true;
            clipboardWrapText = true;
            position = "center";
            pinnedApps = [];
            useApp2Unit = false;
            sortByMostUsed = true;
            terminalCommand = "kitty -e";
            customLaunchPrefixEnabled = false;
            customLaunchPrefix = "";
            viewMode = "grid";
            showCategories = false;
            iconMode = "tabler";
            showIconBackground = false;
            enableSettingsSearch = true;
            ignoreMouseInput = false;
            screenshotAnnotationTool = "";
          };
          controlCenter = {
            position = "close_to_bar_button";
            diskPath = "/";
            shortcuts = {
              left = [
                {
                  id = "WallpaperSelector";
                }
              ];
              right = [
                {
                  id = "Notifications";
                }
                {
                  id = "KeepAwake";
                }
                {
                  id = "NightLight";
                }
              ];
            };
            cards = [
              {
                enabled = true;
                id = "profile-card";
              }
              {
                enabled = true;
                id = "shortcuts-card";
              }
              {
                enabled = true;
                id = "audio-card";
              }
              {
                enabled = true;
                id = "weather-card";
              }
              {
                enabled = true;
                id = "media-sysmon-card";
              }
            ];
          };
          systemMonitor = {
            cpuWarningThreshold = 80;
            cpuCriticalThreshold = 90;
            tempWarningThreshold = 80;
            tempCriticalThreshold = 90;
            gpuWarningThreshold = 80;
            gpuCriticalThreshold = 90;
            memWarningThreshold = 80;
            memCriticalThreshold = 90;
            swapWarningThreshold = 80;
            swapCriticalThreshold = 90;
            diskWarningThreshold = 80;
            diskCriticalThreshold = 90;
            cpuPollingInterval = 3000;
            tempPollingInterval = 3000;
            gpuPollingInterval = 3000;
            enableDgpuMonitoring = true;
            memPollingInterval = 3000;
            diskPollingInterval = 30000;
            networkPollingInterval = 3000;
            loadAvgPollingInterval = 3000;
            useCustomColors = false;
            warningColor = "#94e2d5";
            criticalColor = "#f38ba8";
            externalMonitor = "resources || missioncenter || jdsystemmonitor || corestats || system-monitoring-center || gnome-system-monitor || plasma-systemmonitor || mate-system-monitor || ukui-system-monitor || deepin-system-monitor || pantheon-system-monitor";
          };
          dock = {
            enabled = false;
            position = "bottom";
            displayMode = "auto_hide";
            backgroundOpacity = 0.2;
            floatingRatio = 1;
            size = 1;
            onlySameOutput = true;
            monitors = [];
            pinnedApps = [];
            colorizeIcons = false;
            pinnedStatic = false;
            inactiveIndicators = false;
            deadOpacity = 0.6;
            animationSpeed = 1;
          };
          network = {
            wifiEnabled = false;
            bluetoothRssiPollingEnabled = false;
            bluetoothRssiPollIntervalMs = 10000;
            wifiDetailsViewMode = "grid";
            bluetoothDetailsViewMode = "grid";
            bluetoothHideUnnamedDevices = false;
          };
          sessionMenu = {
            enableCountdown = true;
            countdownDuration = 10000;
            position = "center";
            showHeader = true;
            largeButtonsStyle = true;
            largeButtonsLayout = "grid";
            showNumberLabels = true;
            powerOptions = [
              {
                action = "lock";
                command = "";
                countdownEnabled = true;
                enabled = true;
              }
              {
                action = "suspend";
                command = "";
                countdownEnabled = true;
                enabled = true;
              }
              {
                action = "hibernate";
                command = "";
                countdownEnabled = true;
                enabled = true;
              }
              {
                action = "reboot";
                command = "";
                countdownEnabled = true;
                enabled = true;
              }
              {
                action = "logout";
                command = "";
                countdownEnabled = true;
                enabled = true;
              }
              {
                action = "shutdown";
                command = "";
                countdownEnabled = true;
                enabled = true;
              }
            ];
          };
          notifications = {
            enabled = true;
            monitors = [
              "DP-1"
            ];
            location = "top_right";
            overlayLayer = true;
            backgroundOpacity = 0.76;
            respectExpireTimeout = false;
            lowUrgencyDuration = 3;
            normalUrgencyDuration = 8;
            criticalUrgencyDuration = 15;
            enableKeyboardLayoutToast = true;
            saveToHistory = {
              low = true;
              normal = true;
              critical = true;
            };
            sounds = {
              enabled = false;
              volume = 0.5;
              separateSounds = false;
              criticalSoundFile = "";
              normalSoundFile = "";
              lowSoundFile = "";
              excludedApps = "discord,firefox,chrome,chromium,edge";
            };
            enableMediaToast = false;
          };
          osd = {
            enabled = true;
            location = "top_right";
            autoHideMs = 2000;
            overlayLayer = true;
            backgroundOpacity = 0.76;
            enabledTypes = [
              0
              1
              2
              3
            ];
            monitors = [
              "DP-1"
            ];
          };
          audio = {
            volumeStep = 5;
            volumeOverdrive = false;
            cavaFrameRate = 60;
            visualizerType = "linear";
            mprisBlacklist = [];
            preferredPlayer = "";
            volumeFeedback = false;
          };
          brightness = {
            brightnessStep = 5;
            enforceMinimum = true;
            enableDdcSupport = false;
          };
          colorSchemes = {
            useWallpaperColors = false;
            predefinedScheme = "Catppuccin";
            darkMode = true;
            schedulingMode = "off";
            manualSunrise = "06:30";
            manualSunset = "18:30";
            generationMethod = "tonal-spot";
            monitorForColors = "";
          };
          templates = {
            activeTemplates = [];
            enableUserTheming = false;
          };
          nightLight = {
            enabled = false;
            forced = false;
            autoSchedule = true;
            nightTemp = "5602";
            dayTemp = "6500";
            manualSunrise = "06:30";
            manualSunset = "18:30";
          };
          hooks = {
            enabled = false;
            wallpaperChange = "";
            darkModeChange = "";
            screenLock = "";
            screenUnlock = "";
            performanceModeEnabled = "";
            performanceModeDisabled = "";
            startup = "";
            session = "";
          };
          desktopWidgets = {
            enabled = true;
            gridSnap = false;
            monitorWidgets = [
              {
                name = "DP-2";
                widgets = [
                  {
                    hideMode = "visible";
                    id = "MediaPlayer";
                    roundedCorners = true;
                    scale = 1.6484942;
                    showAlbumArt = true;
                    showBackground = true;
                    showButtons = true;
                    showVisualizer = true;
                    visualizerType = "wave";
                    x = 10;
                    y = 6;
                  }
                  {
                    clockStyle = "digital";
                    customFont = "";
                    format = "HH:mm\\nd MMMM yyyy";
                    id = "Clock";
                    roundedCorners = true;
                    scale = 1.4308195;
                    showBackground = true;
                    useCustomFont = false;
                    usePrimaryColor = false;
                    x = 7;
                    y = 165;
                  }
                ];
              }
            ];
          };
        };
      };
    };
  };
}
