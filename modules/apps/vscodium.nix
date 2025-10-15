	# Config for VS Codium
	{ pkgs, ... }:
	{
		# Config done in home-manager
		home-manager.users.suzu = {
			programs.vscode = {
				enable= true;
				package = pkgs.vscodium;

				# Declarative extensions
				profiles.default.extensions = with pkgs.vscode-extensions; [
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
				profiles.default.userSettings = {
					"workbench.iconTheme" = "vscode-icons";

					# Wayland decorations config
					"window.titleBarStyle" = "native";

					# Specific language configuration
					"[nix]" = {
						"editor/tabSize" = 2;
					};
				};
			};
		};
	}
