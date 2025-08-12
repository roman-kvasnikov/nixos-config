# Общие настройки для всех хостов
{
  # Информация о пользователе
  user = {
    name = "romank";
  };

  hosts = let
    hostList = [
      { hostname = "huawei"; }
      { hostname = "nixos"; }
      { hostname = "nixos-vm"; }
    ];

    hostDefaults = {
      system = "x86_64-linux";
      version = "25.05";
    };
  in
    map (host: hostDefaults // host) hostList;
}