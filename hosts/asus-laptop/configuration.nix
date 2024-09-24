{ configVars, ... }:
{
  imports =
    [
      # Core configuration
      ../common/core
      ../common/core/sops.nix
      ../common/core/locale.nix
      ../common/users

      # Include the results of the hardware scan.
      ./system

      # Services 
      ./services

      # Programs and Applications
      ./packages

    ];

  # Define a user account. Don't forget to set a password with ‘passwd’.
  # users.users.nicoswan = {
  #   isNormalUser = true;
  #   description = "Nico Swan";
  #   extraGroups = [ "networkmanager" "wheel" ];
  #   openssh.authorizedKeys.keys = [
  #     "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJzDICPeNfXXLIEnf4FEQ5ZGX6REsNEPaeRbyxOh7vVL NicoMacLaptop"
  #   ];
  #   shell = pkgs.zsh; # default shell
  # };




  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  system.stateVersion = configVars.stateVersion;

}
