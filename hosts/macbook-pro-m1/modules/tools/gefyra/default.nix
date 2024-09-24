{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.gefyra;
in
{
  options.programs.gefyra = {
    enable = mkEnableOption "Enable Gefyra";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
     (pkgs.stdenv.mkDerivation {
        name = "gefyra";
        src = pkgs.fetchzip {
          url = "https://github.com/gefyrahq/gefyra/releases/download/2.2.2/gefyra-2.2.2-darwin-universal.zip";
          sha256 = "16hll43rp87g71lxk364w4hpc5n3ckvsmqzjcmhqmh6pkkzblspk";
          stripRoot = false;
        };

        phases = [ "unpackPhase" "installPhase" ];

        installPhase = ''
          mkdir -p $out/bin
          cp -r $src/* $out/bin/
          chmod +x $out/bin/gefyra
        '';
      })
    ];
  };
}
