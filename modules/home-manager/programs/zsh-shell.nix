{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.programs.zsh-shell;
in {

  options.programs.zsh-shell = {
    enable = mkEnableOption "Nico Swan zsh shell setup.";
  };

  config =  mkIf cfg.enable {

    programs = {
      zsh = {
        enable = true;
        shellAliases = {
          nix-shell = "nix-shell --run zsh";
          la = "eza  --long -a --group-directories-first --icons=always --color=auto --almost-all --time-style=long-iso";
          ll = "la --long --no-user --no-time --no-permissions --no-filesize";
          cat = "bat -p";
          grep = "grep --color=auto";
          egrep = "egrep --color=auto";
          fgrep = "fgrep --color=auto";
        };
        enableCompletion = true;
        autosuggestion.enable = true;
        history = {
          size = 10000;
          path = "${config.xdg.dataHome}/zsh/history";
          expireDuplicatesFirst = true;
        };
        historySubstringSearch.enable = true;
        syntaxHighlighting.enable = true;

        sessionVariables = {
          EDITOR = "vi";
          SOPS_AGE_KEY_FILE = "${config.xdg.dataHome}/.config/sops/age/keys.txt";
        };
      };
    };
  };  
}