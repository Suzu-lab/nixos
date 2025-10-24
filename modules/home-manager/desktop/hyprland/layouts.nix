	# Split module for setting up Hyprland layouts
	{ lib, pkgs, config, ... }:
	{
		wayland.windowManager.hyprland = {
			settings = {

				# Set the default layout between dwindle or master
				general.layout = "scrolling";

				# See https://wiki.hyprland.org/Configuring/Dwindle-Layout/ for more
				dwindle = {
					# Tile floating windows
					pseudotile = "true";

					# Split to the right side only (bspwm style)
					force_split = 2;

					# Don't change splits on resize
					preserve_split = "true";

					# Split based on cursor position
					smart_split = "false";

					# Default split ratio (1 means even 50/50 split) [0.1 - 1.9]
					default_split_ratio = 1;

					# Specifies a scale factor of the windows on the special workspace [0-1]
					special_scale_factor = 1;
				};

				# See https://wiki.hyprland.org/Configuring/Master-Layout/ for more
				master = {
					# If new windows created will take the spot of the "master" window or if they will become a "slave" window (can also "inherit" the status of the focused window)
					new_status = "slave";

					# Allow for the use of more than one Master window
					allow_small_split = true;

					# Percentage of the screen the Master will take [0-1]
					mfact = 0.5;

					# Define if newly opened windows should be on top of the slave stack
					new_on_top = true;

					# Define if the new window will be placed "before" or "after" the focused window. "none" follows the setting of new_on_top
					new_on_active = "none";

					# Resize windows based on mouse cursor
					smart_resizing = true;

					# If enabled, dragging/dropping windows will put them exactly at mouse cursor. If disabled, they'll follow new_on_top
					drop_at_cursor = true;

					# Keeps the master window at the split size even if there are no slaves
					always_keep_position = false;

					# Specifies a scale factor of the windows on the special workspace [0-1]
					special_scale_factor = 1;
				};

				# Settings for the hyprscrolling layout plugin. Comment out if not using hyprscrolling
				plugin = {
					hyprscrolling = {
						# If windows will be fullscreen while alone
						fullscreen_on_one_column = "true";

						# The default percentage of screen width each window will take
						column_width = 0.5;

						# Method to use to bring a focused column into view. 0 - center, 1 - fit
						focus_fit_method = 0;

						# If the layout will move to make a focused window to be fully visible
						follow_focus = "true";

						# List of predetermined column widths to change with +conf and -conf keybinds
						explicit_column_widths = "0.333, 0.5, 0.667, 1.0";
					};
				};
			};
		};
	}
