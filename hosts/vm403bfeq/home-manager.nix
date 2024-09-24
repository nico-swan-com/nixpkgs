{ ... }:
{
  imports = [
    # All user manditory configuration and packages
    ../../home/common/core

    # Optional packages and configiration for this host
    ../../home/common/optional/sops.nix

  ];
}
