# Declarative configuration for Noctalia-shell

{ pkgs, inputs, noctalia-shell, ... }:
{
  imports = [
    inputs.noctalia-shell.homeModules.default
  ];

  programs.noctalia-shell = {
    enable = true;
    systemd.enable = true;  # Autostarts the shell as a systemd service.
    settings = {
      settingsVersion = 20;
      setupCompleted = true;
      bar = {
        position = "top";
        backgroundOpacity = 0;
        monitors = [ "DP-1" ];
        density = "comfortable";
        showCapsule = true;
        floating = true;
        marginVertical = 0.20;
        marginHorizontal = 0.25;
        outerCorners = true;
        exclusive = true;
        widgets = {
          left = [
            {
              id = "ControlCenter";
              useDistroLogo = true;
              icon = "noctalia";
              customIconPath = "";
            }
            {
              id = "SystemMonitor";
              showCpuUsage = true;
              showCpuTemp = true;
              showMemoryUsage = true;
              showMemoryAsPercent = true;
              showNetworkStats = true;
              showDiskUsage = false;
            }
            {
              id = "ActiveWindow";
              showIcon = true;
              hideMode = "hidden";
              scrollingMode = "hover";
              width = 145;
              colorizeIcons = true;
            }
            {
              id = "MediaMini";
              hideMode = "hidden";
              scrollingMode = "hover";
              maxWidth = 145;
              useFixedWidth = false;
              showAlbumArt = false;
              showVisualizer = true;
              visualizerType = "wave";
            }
          ];
          center = [
            {
              id = "Workspace";
              labelMode = "index";
              hideUnoccupied = true;
              characterCount = 2;
            }
          ];
          right = [
            {
              id = "ScreenRecorder";
            }
            {
              id = "Tray";
              blacklist = [];
              colorizeIcons = true;
            }
            {
              id = "NotificationHistory";
              showUnreadBadge = true;
              hideWhenZero = true;
            }
#            {
#              id = "Battery";
#              displayMode = "onhover";
#              warningThreshold = 30;
#            }
            {
              id = "Volume";
              displayMode = "onhover";
            }
#            {
#              id = "Brightness";
#              displayMode = "onhover";
#            }
            {
              id = "Clock";
              usePrimaryColor = true;
              useCustomFont = false;
              customFont = "";
              formatHorizontal = "HH:mm ddd, MMM dd";
              formatVertical = "HH mm - dd MM";
            }
          ];
        };
      };
      general = {
        avatarImage = "~/Images/Profile Pics/Cereal Experiments Lain.png";
        dimDesktop = true;
        showScreenCorners = false;
        forceBlackScreenCorners = false;
        scaleRatio = 1;
        radiusRatio = 0.5;
        screenRadiusRatio = 1;
        animationSpeed = 1;
        animationDisabled = false;
        compactLockScreen = false;
        lockOnSuspend = true;
        enableShadows = false;
        shadowDirection = "bottom_right";
        shadowOffsetX = 2;
        shadowOffsetY = 3;
        language = "";
      };
      ui = {
        fontDefault = "Noto Sans";
        fontFixed = "Noto Sans Mono";
        fontDefaultScale = 1.1;
        fontFixedScale = 1.1;
        tooltipsEnabled = true;
        panelsAttachedToBar = true;
        settingsPanelAttachToBar = false;
      };
      location = {
        name = "Porto Alegre/RS";
        weatherEnabled = true;
        useFahrenheit = false;
        use12hourFormat = false;
        showWeekNumberInCalendar = false;
        showCalendarEvents = true;
        showCalendarWeather = true;
        analogClockInCalendar = false;
        firstDayOfWeek = -1;
      };
      screenRecorder = {
        directory = "";
        frameRate = 60;
        audioCodec = "opus";
        videoCodec = "h264";
        quality = "very_high";
        colorRange = "limited";
        showCursor = true;
        audioSource = "default_output";
        videoSource = "portal";
      };
      wallpaper = {
        enabled = true;
        overviewEnabled = false;
        directory = "";
        enableMultiMonitorDirectories = true;
        recursiveSearch = false;
        setWallpaperOnAllMonitors = true;
        defaultWallpaper = "";
        fillMode = "crop";
        fillColor = "#000000";
        randomEnabled = true;
        randomIntervalSec = 600;
        transitionDuration = 1500;
        transitionType = "random";
        transitionEdgeSmoothness = 0.05;
        monitors = [
            {
                directory = "~/Wallpapers/Landscape";
                name = "DP-1";
                wallpaper = "~/Wallpapers/Landscape/joezunzun_06_landscape.png";
            }
            {
                directory = "/home/suzu/Wallpapers/Landscape";
                name = "DP-3";
                wallpaper =  "/home/suzu/Wallpapers/Landscape/xzu_05_landscape.png";
            }
            {
                directory = "/home/suzu/Wallpapers/Portrait";
                name = "HDMI-A-1";
                wallpaper = "/home/suzu/Wallpapers/Portrait/guweiz_03_portrait.png";
            }
            {
                directory = "/home/suzu/Wallpapers/Portrait";
                name = "DP-2";
                wallpaper = "/home/suzu/Wallpapers/Portrait/guweiz_29_portrait.png";
            }
        ];
        panelPosition = "follow_bar";
      };
      appLauncher = {
        enableClipboardHistory = false;
        position = "center";
        backgroundOpacity = 0;
        pinnedExecs = [ ];
        useApp2Unit = false;
        sortByMostUsed = true;
        terminalCommand = "xterm -e";
        customLaunchPrefixEnabled = false;
        customLaunchPrefix = "";
      };
      controlCenter = {
        position = "close_to_bar_button";
        shortcuts = {
          left = [
#            {
#              id = "WiFi";
#            }
#            {
#              id = "Bluetooth";
#            }
            {
              id = "ScreenRecorder";
            }
            {
              id = "WallpaperSelector";
            }
          ];
          right = [
            {
              id = "Notifications";
            }
#            {
#              id = "PowerProfile";
#            }
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
      dock = {
        enabled = false;
        displayMode = "always_visible";
        backgroundOpacity = 1;
        floatingRatio = 1;
        size = 1;
        onlySameOutput = true;
        monitors = [ ];
        pinnedApps = [ ];
        colorizeIcons = false;
      };
#      network = {
#        wifiEnabled = true;
#      };
      notifications = {
        enabled = true;
        doNotDisturb = false;
        monitors = [ "DP-1" ];
        location = "top_right";
        overlayLayer = true;
        backgroundOpacity = 1;
        respectExpireTimeout = false;
        lowUrgencyDuration = 3;
        normalUrgencyDuration = 8;
        criticalUrgencyDuration = 15;
      };
      osd = {
        enabled = true;
        location = "top_right";
        monitors = [ ];
        autoHideMs = 2000;
        overlayLayer = true;
      };
      audio = {
        volumeStep = 5;
        volumeOverdrive = false;
        cavaFrameRate = 60;
        visualizerType = "linear";
        mprisBlacklist = [ ];
        preferredPlayer = "";
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
        matugenSchemeType = "scheme-fruit-salad";
        generateTemplatesForPredefined = true;
      };
      templates = {
        gtk = false;
        qt = false;
        kcolorscheme = false;
        alacritty = false;
        kitty = false;
        ghostty = false;
        foot = false;
        wezterm = false;
        fuzzel = false;
        discord = false;
        discord_vesktop = false;
        discord_webcord = false;
        discord_armcord = false;
        discord_equibop = false;
        discord_lightcord = false;
        discord_dorion = false;
        pywalfox = false;
        vicinae = false;
        walker = false;
        code = false;
        enableUserTemplates = false;
      };
      nightLight = {
        enabled = false;
        forced = false;
        autoSchedule = true;
        nightTemp = "4000";
        dayTemp = "6500";
        manualSunrise = "06:30";
        manualSunset = "18:30";
      };
      hooks = {
        enabled = false;
        wallpaperChange = "";
        darkModeChange = "";
      };
 #     battery = {
 #       chargingMode = 0;
 #     };
    };
  };
}
