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

  # Список всех хостов (объединяется с hostDefaults)
  hosts = let
    hostList = [
      { hostname = "huawei"; }
      { hostname = "nixos"; }
      { hostname = "nixos-vm"; }
    ];
  in
    map (host: hostDefaults // host) hostList;
}