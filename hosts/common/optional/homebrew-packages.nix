{
  #############################################
  #  Packages that is installed via Homebrew  #
  #############################################
  # This is to be used only if the packages and 
  # application is not availible in nix and need 
  # to be installed with homebrew 
  # 
  homebrew.enable = true;
  homebrew.casks = [
    # -- Security --
    #"1password"

    # -- Productivity --
    #"fantastical"
    #"obsidian"
    #"raycast"

    # -- Customisations --
    #"bartender"
    #"hammerspoon"
    #"karabiner-elements"
    #"soundsource"
  ];
}
