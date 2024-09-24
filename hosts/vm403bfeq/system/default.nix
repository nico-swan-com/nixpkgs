{ inputs, ... }:
{
  imports = [
    ../../common/core/nix-settings.nix
    ./hardware-configuration.nix
    ./boot-loader.nix
    ./networking.nix
    ./nfs-server.nix

  ];

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = true;
    settings.PermitRootLogin = "no";
  };

  # Quemu guest agent
  services.qemuGuest.enable = true;

  # Required for remote vscode
  # https://nixos.wiki/wiki/Visual_Studio_Code
  programs.nix-ld.enable = true;

  system.autoUpgrade = {
    enable = true;
    # To see the status of the timer run
    #  systemctl status nixos-upgrade.timer

    # The upgrade log can be printed with this command
    #  systemctl status nixos-upgrade.service
    flake = inputs.self.outPath;
    flags = [
      "--update-input"
      "nixpkgs"
      "-L" # print build logs
    ];
    dates = "02:00";
    randomizedDelaySec = "45min";
  };
}
