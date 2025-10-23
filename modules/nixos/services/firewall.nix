	# Service to open firewall ports
	{config, pkgs, ...}:
	{
		networking.firewall = {
			enable = true;

			# Open ports needed for Discord RTC
			allowedUDPPortRanges = [
				{ from = 10000; to = 60000; }
			];
		};
	}
