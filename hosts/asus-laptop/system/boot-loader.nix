{ pkgs, ... }:
{
  # Bootloader
  boot.plymouth.enable = true;
  boot.loader = {
    grub = {
      enable = true;
      device = "nodev";
      useOSProber = true;
      efiSupport = true;
      configurationLimit = 5;
      copyKernels = true;
      efiInstallAsRemovable = true;
      fsIdentifier = "label";
      #splashImage = ./backgrounds/grub-nixos-3.png;
      #splashMode = "stretch";

      # extraEntries = ''
      #   menuentry "Windows Boot Manager" {
      #     insmod part_gpt
      #     insmod fat
      #     insmod search_fs_uuid
      #     insmod chain
      #     search --fs-uuid --set=root $FS_UUID
      #     chainloader /EFI/Microsoft/Boot/bootmgr.efi
      #   }
      #   menuentry "Reboot" {
      #     reboot
      #   }
      #   menuentry "Poweroff" {
      #     halt
      #   }
      # '';

      theme = pkgs.stdenv.mkDerivation {
        pname = "distro-grub-themes";
        version = "3.1";
        src = pkgs.fetchFromGitHub {
          owner = "AdisonCavani";
          repo = "distro-grub-themes";
          rev = "v3.1";
          hash = "sha256-ZcoGbbOMDDwjLhsvs77C7G7vINQnprdfI37a9ccrmPs=";
        };
        installPhase = "cp -r customize/nixos $out";
      };
    };
  };

}
