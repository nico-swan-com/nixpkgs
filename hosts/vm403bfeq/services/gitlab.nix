{
  services.nginx = {
    virtualHosts."git.cygnus-labs.com" = {
      enableACME = true;
      forceSSL = true;
      locations."/".proxyPass = "http://unix:/run/gitlab/gitlab-workhorse.socket";
    };
  };

  services.gitlab = {
    enable = true;
    databasePasswordFile = "/var/keys/gitlab/db_password";
    initialRootPasswordFile = "/var/keys/gitlab/root_password";
    https = true;
    host = "git.cygnus-labs.com";
    port = 443;
    user = "git";
    group = "git";
    smtp = {
      enable = true;
      address = "localhost";
      port = 25;
    };
    secrets = {
      dbFile = "/var/keys/gitlab/db";
      secretFile = "/var/keys/gitlab/secret";
      otpFile = "/var/keys/gitlab/otp";
      jwsFile = "/var/keys/gitlab/jws";
    };
    extraConfig = {
      gitlab = {
        email_from = "gitlab-no-reply@cygnus-labs.com";
        email_display_name = "Cygnus-Labs GitLab";
        email_reply_to = "gitlab-no-reply@cygnus-labs.com";
        default_projects_features = { builds = false; };
      };
    };
  };
}
