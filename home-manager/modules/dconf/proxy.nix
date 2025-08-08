{lib, config, ...}: 
let
  cfg = config.services.xray-user;
in {
  # Настройка системного прокси через GNOME
  dconf.settings = lib.mkIf cfg.enable {
    "system/proxy" = {
      mode = "manual";
      
      # SOCKS прокси для всего трафика
      socks = {
        host = "127.0.0.1";
        port = 1080;
      };
      
      # HTTP прокси (если нужен)
      # http = {
      #   host = "127.0.0.1";
      #   port = 8080;
      # };
      
      # Игнорировать прокси для локальных адресов
      ignore-hosts = [
        "localhost"
        "127.0.0.0/8"
        "::1"
        "192.168.0.0/16"
        "10.0.0.0/8"
        "172.16.0.0/12"
      ];
    };
  };
}