# module for setting up yazi (file explorer)
{ pkgs, ... }:
{
  hm.programs.yazi = {
    enable = true;
    enableFishIntegration = true;

    # Extra settings and definitions can be found in https://yazi-rs.github.io/docs/configuration/yazi/
    settings = {
      manager = {
        # defines the ratio between the elements of the manager
        ratio = [
          # width of the parent
          1
          # width of the current folder
          4
          # width of the preview
          3
        ];
        sort_by = "natural";
        sort_sensitive = true;
        sort_reverse = false;
        sort_dir_first = true;
        linemode = "mtime";
        show_hidden = false;
        show_symlink = true;
      };

      preview = {
        wrap = "yes";
        tab_size = 1;
        image_filter = "lanczos3";
        image_quality = 90;
        max_width = 600;
        max_height = 900;
        cache_dir = "";
        ueberzug_scale = 1;
        ueberzug_offset = [
          0
          0
          0
          0
        ];
      };

      tasks = {
        micro_workers = 5;
        macro_workers = 10;
        bizarre_retry = 5;
      };

      # rules for apps used to open specific files
      opener = {
        edit = [
          {
            run = "micro \"$@\"";
            block = true;
          }
        ];
        img = [
          {
            run = "imv . \"$@\"";
            orphan = true;
          }
        ];
        office = [
          {
            run = "onlyoffice-desktopeditors --system-title-bar \"$@\"";
            orphan = true;
            desc = "OnlyOffice";
          }
        ];
        pdf = [
          {
            run = "zathura \"$@\"";
            orphan = true;
          }
        ];
      };
      open = {
        rules = [
          {
            mime = "text/*";
            use = "edit";
          }
          {
            mime = "{audio,video}/*";
            use = "play";
          }
          {
            mime = "image/*";
            use = "img";
          }
          {
            mime = "application/{zip,rar,7z*,tar,gzip,xz,zstd,bzip*,lzma,compress,archive,cpio,arj,xar,ms-cab*}";
            use = "extract";
          }
          {
            mime = "application/{json,ndjson}";
            use = "edit";
          }
          {
            mime = "*/javascript";
            use = "edit";
          }
          {
            mime = "inode/empty";
            use = "edit";
          }
          {
            name = "*.xls";
            use = "office";
          }
          {
            name = "*.xlsx";
            use = "office";
          }
          {
            name = "*.doc";
            use = "office";
          }
          {
            name = "*.docx";
            use = "office";
          }
          {
            name = "*.ppt";
            use = "office";
          }
          {
            name = "*.pptx";
            use = "office";
          }
          {
            name = "*.pdf";
            use = [
              "pdf"
              "office"
            ];
          }
        ];
      };
    };
  };
}
