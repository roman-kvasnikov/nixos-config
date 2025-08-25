{
  security = {
    # GNOME keyring integration for PAM services
    pam.services = {
      login.enableGnomeKeyring = true;
      gdm.enableGnomeKeyring = true;
    };

    # Polkit for GNOME
    polkit.enable = true;
  };
}
