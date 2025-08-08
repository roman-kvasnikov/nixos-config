# Модульная организация Xray конфигурации
{...}: {
  imports = [
    ./options.nix   # Определение опций конфигурации
    ./service.nix   # Systemd сервис и директории
    ./config.nix    # Пример конфигурации Xray
    ./commands.nix  # Команды управления xray-user
  ];
}