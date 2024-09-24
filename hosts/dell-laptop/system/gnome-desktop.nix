{ pkgs, ... }:
{

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Gnome default application
  environment.systemPackages = with pkgs; [
    gtop
    libgtop
    gparted
    gnome-extension-manager
  ] ++ (with pkgs.gnomeExtensions; [
    clipboard-history
  ]);

  # Exclde packages installed by default
  environment.gnome.excludePackages = (with pkgs; [
    gnome-photos
    gnome-tour
    gedit # text editor
  ]) ++ (with pkgs.gnomeExtensions; [
    system-monitor
  ]) ++ (with pkgs.gnome; [
    cheese # webcam tool
    gnome-music
    gnome-terminal
    epiphany # web browser
    geary # email reader
    #evince # document viewer
    gnome-characters
    #totem # video player
    tali # poker game
    iagno # go game
    hitori # sudoku game
    atomix # puzzle game
  ]);


  environment.variables = {
    GI_TYPELIB_PATH = "/run/current-system/sw/lib/girepository-1.0";
  };
  services.udev.packages = with pkgs; [ gnome.gnome-settings-daemon ];

  # Auto login configurations
  # services.displayManager.autoLogin.enable = true;
  # services.displayManager.autoLogin.user = "nicoswan";
  # systemd.services."getty@tty1".enable = false;
  # systemd.services."autovt@tty1".enable = false;


  services.xserver.desktopManager.gnome = {
    extraGSettingsOverrides = ''
      [org/gnome/desktop/interface]
      color-scheme='prefer-dark'

      [org.gnome.desktop.background]
      picture-uri='file://${pkgs.nixos-artwork.wallpapers.mosaic-blue.gnomeFilePath}'

      # Favorite apps in gnome-shell
      #[org.gnome.shell]
      #favorite-apps=['org.gnome.Console.desktop', 'org.gnome.Nautilus.desktop']
    '';

    extraGSettingsOverridePackages = [
      pkgs.gsettings-desktop-schemas # for org.gnome.desktop
      pkgs.gnome.gnome-shell # for org.gnome.shell
    ];
  };

}
