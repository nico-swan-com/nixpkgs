{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.programs.nicoswan.starship;
in
{

  options.programs.nicoswan.starship = {
    enable = mkEnableOption "Nico Swan starship default shell decorator setup.";
  };

  config = mkIf cfg.enable {
    programs = {
      starship = {
        enable = true;
        settings = {
          add_newline = true;
          docker_context.disabled = true;
          aws.disabled = true;
          line_break.disabled = false;
          command_timeout = 1000;
        };
      };
    };
  };
}

