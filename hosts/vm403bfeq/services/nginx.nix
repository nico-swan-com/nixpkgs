{

  security.acme = {
    defaults.email = "nico.swan@cygnus-labs.com";
    acceptTerms = true;
  };

  services.nginx = {
    enable = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    virtualHosts = {
      "*.services.production.cygnus-labs.com" = {
        # forceSSL = true;
        # enableACME = true;
        locations."/".proxyPass = "http://172.1.1.2";
      };
    };
  };




}