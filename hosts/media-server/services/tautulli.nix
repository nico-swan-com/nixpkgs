{

  system.activationScripts.tautulliatalink.text = ''
    ln -sfn "/mnt/media_storage/Media/tautulli" "/data/media/tautulli"
  '';

  services.tautulli = {
    enable = true;
    user = "media";
    group = "media";
    openFirewall = true;
    dataDir = "/data/media/tautulli";
  };

}
