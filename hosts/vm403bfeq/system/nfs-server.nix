{ config, lib, pkgs, ... }:
{

  boot.supportedFilesystems = [ "nfs" ];
  services.rpcbind.enable = true;

  systemd.tmpfiles.rules = [
  "d /export 0755 nobody nogroup"
  ];

  services.nfs.server.enable = true;
  # services.nfs.server.exports = ''
  #   /export         192.168.1.10(rw,fsid=0,no_subtree_check) 192.168.1.15(rw,fsid=0,no_subtree_check)
  #   /export/nicoswan  192.168.1.10(rw,nohide,insecure,no_subtree_check) 192.168.1.15(rw,nohide,insecure,no_subtree_check)
  # '';

  # fileSystems."/export/nicoswan" = {
  #   device = "/mnt/nicoswn";
  #   options = [ "bind" ];
  # };

}
