# module for setting up yazi (file explorer)
{ pkgs, ... }:
{
	# Installs the unfree version of _7zz with rar support
	pkgs.yazy.override {_7zz = pkgs._7zz-rar; }
	programs.yazi = {
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
		};
	};
}
