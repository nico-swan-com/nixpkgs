{ config, pkgs, cfg, ... }:
{

    imports = [
       ../modules/home-manager/programs/zsh-shell.nix
    ];
    home.stateVersion = "24.05";

    programs = {
      home-manager.enable = true;

      zsh-shell.enable = true;

      # Set /etc/zshrc
      # zsh = {
      #   enable = true;
      #   shellAliases = {
      #     nix-shell = "nix-shell --run zsh";
      #     la = "eza  --long -a --group-directories-first --icons=always --color=auto --almost-all --time-style=long-iso";
      #     ll = "la --long --no-user --no-time --no-permissions --no-filesize";
      #     cat = "bat -p";
      #     grep = "grep --color=auto";
      #     egrep = "egrep --color=auto";
      #     fgrep = "fgrep --color=auto";
      #   };
      #   enableCompletion = true;
      #   autosuggestion.enable = true;
      #   history = {
      #     size = 10000;
      #     path = "${config.xdg.dataHome}/zsh/history";
      #     expireDuplicatesFirst = true;
      #   };
      #   historySubstringSearch.enable = true;
      #   syntaxHighlighting.enable = true;

      #   sessionVariables = {
      #     EDITOR = "vi";
      #     SOPS_AGE_KEY_FILE = "${config.xdg.dataHome}/.config/sops/age/keys.txt";
      #   };
      # };

      # # Git configuration
      # git = {
      #   enable = true;
      #   userName = cfg.fullname;
      #   userEmail = cfg.email;
      #   extraConfig = {
      #     init.defaultBranch = "main";
      #   };
      # };

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

    # users.users.${cfg.username} = {
    #   #isNormalUser = true;
    #   #extraGroups = [ "sudo" ] 
    #   #++ ifTheyExist [
    #   #  "wheel"
    #   #  "networkmanager" 
    #   #  "docker"
    #   #  "podman"
    #   #  "git"
    #   #];
    #   description = cfg.fullname;
    #   #email = cfg.email;
    # };


    #homeManagerModules.home-manager.users.${cfg.username} = {
    #   programs.alacritty = profiles.overrides.dotfiles.alacritty.settings;
    #   programs.git = profiles.overrides.dotfiles.git.settings;
    #   programs.ssh = {
    #     enable = true;
    #     keys = profiles.overrides.dotfiles.ssh.keys;
    #   };
    #};

  #};
}
