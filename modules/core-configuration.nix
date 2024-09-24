{pkgs, ...}:

{
  programs = {
    zsh = {
      enable = true;
      enableCompletion = true;
      enableFzfCompletion = true;
      enableFzfGit = true;
      enableFzfHistory = true;
    };
  };

environment.systemPackages = with pkgs; [
      zsh
      vim
      nixpkgs-fmt
      nixfmt-classic
      sops
      just
      nil
      nixd
#      (if profiles.roles [ "developer" ] then [ git lvim ] else [ ])
#      (if profiles.roles [ "kubernetes-admin" ] then [ 
#        kubectl 
#        kns 
#        kubernetes-helm
#        k9s
#        helmfile
#        (wrapHelm kubernetes-helm {
#          plugins = with pkgs.kubernetes-helmPlugins; [
#            helm-secrets
#            helm-diff
#            helm-s3
#            helm-git
#          ];
#        })
#      ] else [ ])

      # terminal file managers
      mc

      # archives
      zip
      xz
      unzip
      p7zip

      # utils
      ripgrep # recursively searches directories for a regex pattern
      jq # A lightweight and flexible command-line JSON processor
      yq-go # yaml processor https://github.com/mikefarah/yq
      eza # A modern replacement for ‘ls’
      fzf # A command-line fuzzy finder
      bat # a cat replacement
      tldr # man page replacement
      dust # disk utilization tool
    
      # networking tools
      mtr # A network diagnostic tool
      iperf3
      dnsutils # `dig` + `nslookup`
      ldns # replacement of `dig`, it provide the command `drill`
      aria2 # A lightweight multi-protocol & multi-source command-line download utility
      socat # replacement of openbsd-netcat
      nmap # A utility for network discovery and security auditing
      ipcalc # it is a calculator for the IPv4/v6 addresses

      # misc
      file
      which
      tree
      gnused
      gnutar
      gawk
      zstd
      gnupg
      fswatch

      # nix related
      #
      # it provides the command `nom` works just like `nix`
      # with more details log output
      nix-output-monitor
      nixd # nix language server

      # productivity
      glow # markdown previewer in terminal
      btop # replacement of htop/nmon
      iftop # network monitoring

      # system call monitoring
      lsof # list open files

      # system tools
      pciutils # lspci
      lnav
      kns #Kubernetes namespace switcher

      #Fun 
      cmatrix

    ];    
#};

}
