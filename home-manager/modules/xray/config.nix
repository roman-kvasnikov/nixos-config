{
  lib,
  config,
  ...
}: let
  cfg = config.services.xray-user;
in {
  config = lib.mkIf cfg.enable {
    # Создать пример конфигурации
    home.file.".config/xray/config.example.json" = {
      text = builtins.toJSON {
        log = {
          loglevel = cfg.logLevel;
          access = "${config.home.homeDirectory}/.local/share/xray/access.log";
          error = "${config.home.homeDirectory}/.local/share/xray/error.log";
        };

        # Пример простой конфигурации SOCKS прокси
        inbounds = [{
          port = 1080;
          listen = "127.0.0.1";
          protocol = "socks";
          settings = {
            auth = "noauth";
            udp = true;
          };
          tag = "socks-in";
        }];

        outbounds = [{
          protocol = "freedom";
          settings = {};
          tag = "freedom-out";
        }];

        routing = {
          rules = [{
            type = "field";
            inboundTag = [ "socks-in" ];
            outboundTag = "freedom-out";
          }];
        };
      };
    };
  };
}