{
  imports = [
    ./options.nix # Определение опций конфигурации
    ./service.nix # Systemd сервис и директории
    ./config # Пример конфигурации Xray
    ./commands # Команды управления xray-user
  ];
}
