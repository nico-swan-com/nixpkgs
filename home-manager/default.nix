{ config, pkgs, cfg, ... }:
{

    imports = [
       ../modules/home-manager/programs/zsh.nix
       ../modules/home-manager/programs/starship.nix
    ];

    home.stateVersion = "24.05";

    programs = {
      home-manager.enable = true;

      nicoswan = {
        zsh.enable = true;
        starship.enable = true;
      };

      # Git configuration
      git = {
        enable = true;
        userName = cfg.fullname;
        userEmail = cfg.email;
        extraConfig = {
          init.defaultBranch = "main";
        };
      };

      direnv = {
        enable = true;
        enableZshIntegration = true; # see note on other shells below
        nix-direnv.enable = true;
      };
    };
}
