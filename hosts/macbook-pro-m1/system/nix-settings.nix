{

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  nix = {
    settings = {
      # Necessary for using flakes on this system.
      experimental-features = "nix-command flakes";
      extra-platforms = [ "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      extra-trusted-users = [ "@admin" "@localhost" ];

      # Add needed system-features to the nix daemon
      # Starting with Nix 2.19, this will be automatic
      system-features = [
        "nixos-test"
        "apple-virt"
      ];
    };

    distributedBuilds = true;
    # buildMachines = [{
    #   hostName = "localhost";
    #   sshUser = "builder";
    #   sshKey = "/etc/nix/builder_ed25519";
    #   system = "aarch64-darwin";
    #   maxJobs = 4;
    #   supportedFeatures = [ "kvm" "benchmark" "big-parallel" ];
    # }];

    # Run the linux-builder as a background service
    linux-builder = {
      enable = true;
    };
    # linux-builder = {
    #   enable = true;
    #   ephemeral = true;
    #   maxJobs = 4;
    #   config = {
    #     virtualisation = {
    #       darwin-builder = {
    #         diskSize = 40 * 1024;
    #         memorySize = 8 * 1024;
    #       };
    #       cores = 6;
    #     };
    #   };
    # };

    # Automatic garbage collection to remove unused packages
    gc = {
      user = "root";
      automatic = true;
      interval = {
        Weekday = 1;
        Hour = 0;
        Minute = 0;
      };
      options = "--delete-older-than 30d";
    };
  };

  # launchd.daemons.darwin-builder = {
  #   command = "${linux-builder.config.system.build.macos-builder-installer}/bin/create-builder";
  #   serviceConfig = {
  #     KeepAlive = true;
  #     RunAtLoad = true;
  #     StandardOutPath = "/var/log/darwin-builder.log";
  #     StandardErrorPath = "/var/log/darwin-builder.log";
  #   };
  # };

}
