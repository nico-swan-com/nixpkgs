{ ... }: {
  imports = [
    # All user manditory configuration and packages
    ../../home/common/core

    # Optional packages and configiration for this host
    ../../home/common/optional/sops.nix
    ../../home/common/optional/desktop/fonts.nix
    ../../home/common/optional/terminal/nnn.nix


    #../../packages/custom/read-aloud/home-manager-module.nix
  ];
}
