{ pkgs, ... }:
let
  dataDir = "/data/media/qbittorrent";
  configDir = "${dataDir}/.config";
  openFilesLimit = 4096;
  user = "media";
  group = "media";
  port = 9010;
in
{
  environment.systemPackages = with pkgs; [
    qbittorrent
  ];

  nixpkgs.overlays = [
    (final: prev: {
      qbittorrent = prev.qbittorrent.override { guiSupport = false; };
    })
  ];

  networking.firewall = {
    allowedTCPPorts = [ port ];
    allowedUDPPorts = [ port ];
  };

  systemd.services.qbittorrent = {
    after = [ "network.target" ];
    description = "qBittorrent Daemon";
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.qbittorrent ];
    serviceConfig = {
      ExecStart = ''
        ${pkgs.qbittorrent}/bin/qbittorrent-nox \
          --profile=${configDir} \
          --webui-port=${toString port}
      '';
      # To prevent "Quit & shutdown daemon" from working; we want systemd to
      # manage it!
      Restart = "on-success";
      User = user;
      Group = group;
      UMask = "0002";
      LimitNOFILE = openFilesLimit;
    };
  };

  system.activationScripts.qbittorrentdatalink.text = ''
    ln -sfn "/mnt/media_storage/Media/qbittorrent" /data/media/qbittorrent
  '';

}
