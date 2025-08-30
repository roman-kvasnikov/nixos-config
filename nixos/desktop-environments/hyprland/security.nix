{
  security = {
    # GNOME keyring integration for PAM services
    pam.services = {
      login.enableGnomeKeyring = true;

      hyprlock = {
        # enableGnomeKeyring = true;
      };
    };

    polkit.enable = true;
  };
}
