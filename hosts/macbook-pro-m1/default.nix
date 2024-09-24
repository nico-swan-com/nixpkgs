{ ... }: {

  
  imports = [
    ./darwin-configuration.nix
    ../common/core/sops.nix
  ];

  nicoswan.profiles = {
    enable = true;
  };

}
