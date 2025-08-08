# Общие настройки для всех хостов
{
  # Информация о пользователе
  user = {
    name = "romank";
  };

  # Общие настройки хостов
  hostDefaults = {
    system = "x86_64-linux";
    version = "25.05";
  };

  # Список всех хостов
  hosts = [
    {
      hostname = "nixos";
      system = "x86_64-linux";
      version = "25.05";
    }
    {
      hostname = "nixos-vm";
      system = "x86_64-linux";
      version = "25.05";
    }
  ];
}