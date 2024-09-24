{
  services.radarr = {
    enable = true;
    openFirewall = true;
    dataDir = "/data/media/radarr";
    user = "media";
    group = "media";
  };

  system.activationScripts.radarrdatalink.text = ''
    ln -sfn "/mnt/media_storage/Media/Radarr" /data/media/radarr
  '';
}
