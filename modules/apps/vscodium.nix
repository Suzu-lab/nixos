	# Config for VS Codium
	{ pkgs, ... }:
	{
		# Config done in home-manager
		home-manager.users.suzu = {
			programs.vscode = {
				enable= true;
				package = pkgs.vscodium;

				# Declarative extensions
				extensions = with pkgs.vscode-extensions; [
					# Theme
					catppuccin.catppuccin-vsc

					# Languages and tools
					ms-python.python
					rust-lang.rust-analyzer
					ms-azuretools.vscode-docker
					tamasfe.even-better-toml
					jnoortheen.nix-ide

					# Quality of life
					vscode-icons-team.vscode-icons
					eamodio.gitlens
				];

				# Settings.json config
				userSettings = {
					"workbench.colorTheme" = "Catppuccin Macchiato";
					"workbench.iconTheme" = "vscode-icons";
					"editor.fontFamily" = "'JetBrainsMono Nerd Font', 'monospace'";
					"editor.fontSize" = 14;

					# Wayland decorations config
					"window.titleBarStyle" = "custom";

					# Specific language configuration
					"[nix]" = {
						"editor/tabSize" = 2;
					};
				};
			};
		};
	}
