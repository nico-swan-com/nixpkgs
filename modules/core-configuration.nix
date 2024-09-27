{pkgs, ...}:

{

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  programs = {
    zsh = {
      enable = true;
      enableCompletion = true;
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
      btop # replacement of htop/nmon
      iftop # network monitoring
      lsof # list open files
      fswatch # watch file system events
      git-extras # Some git extra command see https://github.com/tj/git-extras

      #Fun 
      cmatrix
    ];    

}
