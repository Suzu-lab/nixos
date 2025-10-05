  # fish shell configuration for NixOS

  { config, pkgs, ... }:
  {
    # Enabling fish through at system level
    programs.fish = {
      enable = true;
      interactiveShellInit = ''
        set -gx EDITOR micro
        set -gx VISUAL micro
        set -gx PAGER less
      '';
      shellAliases = {
        ll = "ls -lh";
        la = "ls -lha";
        gs = "git status";
        gl = "git log --oneline --graph --decorate";
        edit = "micro";
      };
    };

    programs.starship = {
      enable = true;
      settings = {
        add_newline = false;
        character = { success_symbol = ">"; error_symbol = ">"; };
      };
    };

		home-manager.users.suzu = {
    	# User CLI tools
    	home.packages = with pkgs; [
      	bat btop direnv eza fd micro nh nix-direnv ripgrep
    	];

    	# Define default user shell as Fish
    	home.sessionVariables.SHELL = "${pkgs.fish}/bin/fish";

    	programs.direnv.enable = true;
    	programs.direnv.nix-direnv.enable = true;

    	# Minimal micro editor config
    	xdg.configFile."micro/settings.json".text = ''
    	{
      	"softwrap": true,
      	"tabsize": 2,
      	"autosu": true,
      	"clipboard": "external",
      	"mkparents": true,
      	"rmtrailingws": true
    	}
    	'';
    };
  }
