{

  security.acme = {
    defaults.email = "hi@nicoswan.com";
    acceptTerms = true;
  };

  services.nginx= {
    enable = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
  };
 
  services.nginx.virtualHosts =
    let
      COMMON = {
        enableACME = true;
        forceSSL = true;
      };
    in
    {
      "plex.home.nicoswan.com" = (COMMON // {
        http2 = true;
        locations."/".proxyPass = "http://127.0.0.1:32400/";
      });

      "radarr.home.nicoswan.com" = (COMMON // {
        locations."/".proxyPass = "http://127.0.0.1:7878/";
      });

      "sonarr.home.nicoswan.com" = (COMMON // {
        locations."/".proxyPass = "http://127.0.0.1:8989/";
      });

      "ombi.home.nicoswan.com" = (COMMON // {
        locations."/".proxyPass = "http://127.0.0.1:5000/";
      });

      "qbittorrent.home.nicoswan.com" = (COMMON // {
        locations."/".proxyPass = "http://127.0.0.1:9010/";
      });
      
      "jackett.home.nicoswan.com" = (COMMON // {
        locations."/".proxyPass = "http://127.0.0.1:9117/";
      });

      "tautulli.home.nicoswan.com" = (COMMON // {
        locations."/".proxyPass = "http://127.0.0.1:8181/";
      });

    };
}


