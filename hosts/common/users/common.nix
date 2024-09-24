{ pkgs, config, configVars, ... }:
{
  ${configVars.username} = {
    name = configVars.username;
    home =
      if pkgs.stdenv.isLinux
      then "/home/${configVars.username}"
      else "/Users/${configVars.username}";
  };
}
