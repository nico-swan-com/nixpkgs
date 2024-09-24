{ pkgs, inputs, config, configVars, ... }:
let
  secretsDirectory = builtins.toString inputs.nix-secrets;
  secretsFile = "${secretsDirectory}/cygnus-labs.com.vm403bfeq.yaml";

  # FIXME: Switch to a configLib function
  # this is some stuff for distinguishing linux from darwin. Likely just remove it.
  homeDirectory =
    if pkgs.stdenv.isLinux
    then "/home/${configVars.username}"
    else "/Users/${configVars.username}";
in
{
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];

  sops = {
    defaultSopsFile = "${secretsFile}";
    validateSopsFiles = false;

    age = {
      # automatically import host SSH keys as age keys
      sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    };

    # secrets will be output to /run/secrets
    # e.g. /run/secrets/msmtp-password
    # secrets required for user creation are handled in respective ./users/<username>.nix files
    # because they will be output to /run/secrets-for-users and only when the user is assigned to a host.
    secrets = {
      # For home-manager a separate age key is used to decrypt secrets and must be placed onto the host. This is because
      # the user doesn't have read permission for the ssh service private key. However, we can bootstrap the age key from
      # the secrets decrypted by the host key, which allows home-manager secrets to work without manually copying over
      # the age key.
      "age_keys/${config.networking.hostName}" = {
        owner = config.users.users.${configVars.username}.name;
        inherit (config.users.users.${configVars.username}) group;
        # We need to ensure the entire directory structure is that of the user...
        path = "${homeDirectory}/.config/sops/age/keys.txt";
      };

      # extract username/password to /run/secrets-for-users/ so it can be used to create the user
      "users/vmbfeqcy/password".neededForUsers = true;


    };
  };
}
