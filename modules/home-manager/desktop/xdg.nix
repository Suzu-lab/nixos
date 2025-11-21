{ config, pkgs, ...}:
{
  # XDG configurations for standardizing the desktop config

  # Installing cli tools for checking xdg and the special user dirs
  home.packages = with pkgs; [
    xdg-utils
    xdg-user-dirs
  ];

  xdg = {
    configFile."mimeapps.list".force = true;
    enable = true;
    cacheHome = "${config.home.homeDirectory}/.cache";
    configHome = "${config.home.homeDirectory}/.config";
    dataHome = "${config.home.homeDirectory}/.local/share";
    stateHome = "${config.home.homeDirectory}/.local/state";

    # Configure default applications to open files
    mimeApps = {
      enable = true;
      defaultApplications = 
      let
        browser = [
          "floorp.desktop"
        ];
        editor = [
          "codium.desktop"
        ];
        office = [
          "onlyoffice-desktopeditors.desktop"
        ];
        player = [
          "mpv.desktop"
        ];
        viewer = [
          "imv-dir.desktop"
        ];
      in 
      { 
        # Default file associations
        "application/doc" = office;
        "application/docx" = office;
        "application/json" = browser;
        "application/pdf" = office;
        "application/ppt" = office;
        "application/pptx" = office;
        "application/rdf+xml" = browser;
        "application/rss+xml" = browser;
        "application/xls" = office;
        "application/xlsx" = office;
        "application/xml" = browser;
        "application/xhtml+xml" = browser;
        "application/xhtml_xml" = browser;

        "application/x-extension-htm" = browser;
        "application/x-extension-html" = browser;
        "application/x-extension-shtml" = browser;
        "application/x-extension-xht" = browser;
        "application/x-extension-xhtml" = browser;
        "application/x-wine-extension-ini" = editor;
        
        "text/plain" = editor;
        "text/html" = browser;
        "text/xml" = browser;

        # Default application for url schemes
        "x-scheme-handler/about" = browser;
        "x-scheme-handler/chrome" = browser;
        "x-scheme-handler/ftp" = browser;
        "x-scheme-handler/https" = browser;
        "x-scheme-handler/http" = browser;
        "x-scheme-handler/mailto" = browser;
        "x-scheme-handler/unknown" = browser;

        # Media files
        "audio/*" = player;
        "video/*" = player;
        "image/*" = viewer;
        "image/gif" = viewer;
        "image/jpeg" = viewer;
        "image/png" = viewer;
        "image/webp" = viewer;
      };
    };

    # Enables the home folder special dirs and creates a special dir for saving screenshots
    userDirs = {
      enable = true;
      createDirectories = true;
      extraConfig = {
        XDG_SCREENSHOTS_DIR = "${config.xdg.userDirs.pictures}/Screenshots";
      };
    };
  };
}