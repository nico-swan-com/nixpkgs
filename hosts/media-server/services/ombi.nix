{ pkgs, ... }:
{

  system.activationScripts.ombidatalink.text = ''
    ln -sfn "/mnt/media_storage/Media/Ombi" "/data/media/ombi"
  '';

  services.ombi = {
    enable = true;
    user = "media";
    group = "media";
    dataDir = "/data/media/ombi";
    openFirewall = true;
  };

}
