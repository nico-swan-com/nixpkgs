{


  system.activationScripts.transmissiondatalink.text = ''
    ln -sfn "/mnt/media_storage/Media/transmission" "/data/media/transmission"
  '';

  services.transmission = {
    enable = true;
    user = "media";
    group = "media";
    openFirewall = true;
    home = "/data/media/transmission";
  };

}
