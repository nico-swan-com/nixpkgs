{ pkgs, inputs, config, lib, configVars, configLib, ... }:
let
  ifTheyExist = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
  sopsHashedPasswordFile = lib.optionalString (lib.hasAttr "sops-nix" inputs) config.sops.secrets."users/${configVars.username}/password".path;
  rootHashedPasswordFile = lib.optionalString (lib.hasAttr "sops-nix" inputs) config.sops.secrets."users/root/password".path;
  pubKeys = lib.filesystem.listFilesRecursive (./keys);

  # these are values we don't want to set if the environment is minimal. E.g. ISO or nixos-installer
  # isMinimal is true in the nixos-installer/flake.nix
  fullUserConfig = lib.optionalAttrs (!(lib.hasAttr "isMinimal" configVars))
    {
      users.mutableUsers = false; # Required for password to be set via sops during system activation!
      users.users.${configVars.username} = {
        hashedPasswordFile = sopsHashedPasswordFile;
        packages = [ pkgs.home-manager ];
      };

      # Import this user's personal/home configurations
      home-manager.users.${configVars.username} = import (configLib.relativeToRoot "home/users/${configVars.username}/${config.networking.hostName}.nix");
    };
in
{
  config = lib.recursiveUpdate fullUserConfig
    #this is the second argument to recursiveUpdate
    {
      users.users.${configVars.username} = {
        isNormalUser = true;
        password = "nixos"; # Overridden if sops is working

        description = configVars.fullName;
        home =
          if pkgs.stdenv.isLinux
          then "/home/${configVars.username}"
          else "/Users/${configVars.username}";

        extraGroups = [
          "wheel"
        ] ++ ifTheyExist [
          "audio"
          "video"
          "docker"
          "podman"
          "git"
          "networkmanager"
        ];

        # These get placed into /etc/ssh/authorized_keys.d/<name> on nixos
        openssh.authorizedKeys.keys = lib.lists.forEach pubKeys (key: builtins.readFile key);

        shell = pkgs.zsh; # default shell
      };

      # Proper root use required for borg and some other specific operations
      users.users.root = {
        hashedPasswordFile = rootHashedPasswordFile;
        password = lib.mkForce config.users.users.${configVars.username}.password;
        # root's ssh keys are mainly used for remote deployment.
        openssh.authorizedKeys.keys = config.users.users.${configVars.username}.openssh.authorizedKeys.keys;
      };

      # No matter what environment we are in we want these tools for root, and the user(s)
      programs.zsh.enable = true;
      programs.git.enable = true;
      environment.systemPackages = [
        pkgs.just
        pkgs.rsync
      ];
    };
}
