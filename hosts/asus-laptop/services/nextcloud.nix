{ pkgs, ... }:
{
  services.nextcloud = {
    enable = true;
    hostName = "nextcloud.home.nicoswan.com";
    database.createLocally = true;
    config = {
      dbtype = "pgsql";
      adminpassFile = "/path/to/admin-pass-file";
    };
  };

  networking.firewall.allowedTCPPorts = [ 80 443 ];
}
