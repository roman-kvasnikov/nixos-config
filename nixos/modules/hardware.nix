{pkgs, ...}: {
  hardware = {
    # Bluetooth
    bluetooth = {
      enable = true;

      powerOnBoot = true;
      settings.General.Experimental = true; # Для новых функций
    };

    # Подсветка клавиатуры
    keyboard.qmk.enable = true;
  };
}
