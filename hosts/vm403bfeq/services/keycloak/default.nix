{ ... }:
{
  services.keycloak = {
    enable = true;

    database = {
      type = "postgresql";
      createLocally = true;

      username = "keycloak";
      passwordFile = "/etc/nixos/secrets/keycloak_psql_pass";
    };

    settings = {
      hostname = "domain.tld";
      http-relative-path = "/cloak";
      http-port = 38080;
      proxy = "passthrough";
      http-enabled = true;
    };
  };
}