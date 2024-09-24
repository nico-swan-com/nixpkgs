{ config, pkgs, cfg, ... }:
{

    imports = [
       ../modules/home-manager/programs/zsh-shell.nix
    ];

    home.stateVersion = "24.05";

    programs = {
      home-manager.enable = true;

      zsh-shell.enable = true;

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

      starship = {
        enable = true;
        settings = {
          add_newline = true;
          docker_context.disabled = true;
          aws.disabled = true;
          gcloud.disabled = true;
          line_break.disabled = false;
          command_timeout = 1000;
        };
      };

      lazygit = {
        enable = true;
        # custom settings
        # settings = {};
      };

      nnn = {
        enable = true;
        package = pkgs.nnn.override ({ withNerdIcons = true; });
        # plugins = {
        # };
      };
  
    };

    # List packages installed in system profile. To search by name, run:
    # $ nix-env -qaP | grep wget
    #   #      (if ! pkgs.env.isLinux then [ terminal-notifier ] else [ ])
    #   #
    #   #      (if profiles.roles [ "developer" ] then [ git lvim ] else [ ])
    #   #      (if profiles.roles [ "kubernetes-admin" ] then [ 
    #   #        kubectl 
    #   #        kns 
    #   #        kubernetes-helm
    #   #        k9s
    #   #        helmfile
    #   #        (wrapHelm kubernetes-helm {
    #   #          plugins = with pkgs.kubernetes-helmPlugins; [
    #   #            helm-secrets
    #   #            helm-diff
    #   #            helm-s3
    #   #            helm-git
    #   #          ];
    #   #        })
    #   #      ] else [ ])
}
