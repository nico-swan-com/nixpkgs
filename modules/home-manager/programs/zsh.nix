{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.programs.nicoswan.zsh;
in
{

  options.programs.nicoswan.zsh = {
    enable = mkEnableOption "Nico Swan zsh shell setup.";
  };

  config = mkIf cfg.enable {
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

        initExtra = ''
          # Add a .zshrc-custom file to the home directory for customizations.
          # This is a good place to add aliases, functions and other things that
          # you don't want in your config. 
          #
          # Note: This should really be used with nix as you can use the home-manager.programs.zsh 
          #        configutation to setup you .zshrc file.
          if [ -f $HOME/.zshrc-custom ]; then
            source $HOME/.zshrc-custom
          fi  
        '';

      };
    };
  };
}
