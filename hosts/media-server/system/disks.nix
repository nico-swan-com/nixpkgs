{
  fileSystems."/mnt/media_storage" =
    {
      device = "/dev/sdb2";
      fsType = "ntfs-3g";
      options = [ "rw" ];
    };

  fileSystems."/mnt/ntfs_drive" =
    {
      device = "/dev/sda2";
      fsType = "ntfs-3g";
      options = [ "rw" ];
    };


  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/sdc";
        content = {
          type = "gpt";
          partitions = {
            boot = {
              size = "1M";
              type = "EF02"; # for grub MBR
              priority = 1; # Needs to be first partition
            };
            ESP = {
              size = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };
            root = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
              };
            };
          };
        };
      };
    };
  };

}
