	# gThumb config
	{ pkgs, ... }:
	{
		# Install through Home-Manager
		home-manager.users.suzu.home.packages = with pkgs; [
			# Installed with plugins
			gthumb
		];

		# Declaractive config through dconf
		home-manager.users.suzu.dconf.settings = {
			"org/gnome/gThumb/browser" = {
				# Ignore hidden files by default
				show-hidden = false;
				# Determine default order as modification date (newest to oldest)
				default-sort-order = "date-desc";
				# Define classification order
				default-sort-by = "mtime";
			};

			"org/gnome/gThumb/viewer" = {
				# Use high quality for zoom interpolation
				default-zoom-quality = "high";
				# Show toolbar in view mode
				toolbar-visible = true;
			};

			"org/gnome/gThumb/general" = {
				# Set recursive searh in folders
				recursive-search = true;
			};
		};
	}
