{config, pkgs, cfg, ...}:
let 
  ifGroupsExist = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
in
{
  imports = [
    # Core must have system installations
    ../modules/core-configuration.nix
  ];

  users.users.${cfg.username} = {
      isNormalUser = true;
      extraGroups = [ "sudo" ] 
      ++ ifGroupsExist [
        "wheel"
        "networkmanager" 
        "docker"
        "podman"
        "git"
      ];
    };

  # NixOS/Linux packages not availible for nix-darwin
  environment.systemPackages = with pkgs; [
    # # utils
    ncdu # disk usage uitls   
    rmlint # remove duplicate file
    rsync # fast copy
    # rclone # fast copy to cloud providers like minio
    # ntfy # terminal notification 

    # iotop # io monitoring
    # iftop # network monitoring

    # # system call monitoring
    # strace # system call monitoring
    # ltrace # library call monitoring
    lsof # list open files

    # # system tools
    # sysstat
    # lm_sensors # for `sensors` command
    # ethtool
    # pciutils # lspci
    # usbutils # lsusb
  ];
}
