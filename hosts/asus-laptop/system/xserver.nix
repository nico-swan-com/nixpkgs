{ ... }:
{

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Configure keymap in X11
  services.xserver = {
    xkb.layout = "za";
    xkb.variant = "";
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Auto Login
  # services.displayManager.autoLogin.enable = true;
  # services.displayManager.autoLogin.user = "nicoswan";

}
