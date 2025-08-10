{
  security = {
    # AppArmor для дополнительной безопасности
    apparmor = {
      enable = true;
      killUnconfinedConfinables = true;
    };

    # Sudo настройки для удобства
    sudo = {
      enable = true;
      wheelNeedsPassword = false;   # Отключить пароль для wheel (удобно)
      execWheelOnly = true;         # Только wheel может использовать sudo
    };

    # PAM оптимизации
    pam = {
      loginLimits = [{
        domain = "*";
        type = "soft";
        item = "nofile";
        value = "65536"; # Больше открытых файлов
      }];

      services = {
        login.enableGnomeKeyring = true;
        gdm.enableGnomeKeyring = true;
      };
    };

    # Современные security settings
    rtkit.enable = true;
    polkit.enable = true;
  };
}
