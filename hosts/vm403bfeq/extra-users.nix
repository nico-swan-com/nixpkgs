{ pkgs, config, lib, inputs, ... }:
let
  ifTheyExist = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
  sopsHashedPasswordFile = lib.optionalString (lib.hasAttr "sops-nix" inputs) config.sops.secrets."users/vmbfeqcy/password".path;
  pubKeys = lib.filesystem.listFilesRecursive (../common/users/keys);
in
{
  users.users.vmbfeqcy = {
    isNormalUser = true;
    description = "Nico Swan";
    hashedPasswordFile = sopsHashedPasswordFile;
    # These get placed into /etc/ssh/authorized_keys.d/<name> on nixos
    openssh.authorizedKeys.keys = lib.lists.forEach pubKeys (key: builtins.readFile key);
    extraGroups = [
          "wheel"
        ] ++ ifTheyExist [
          "docker"
          "podman"
          "git"
          "networkmanager"
        ];
    shell = pkgs.zsh; # default shell
    packages = with pkgs; [ ];
  };
}
