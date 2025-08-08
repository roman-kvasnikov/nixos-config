{lib, config, ...}: {
  config = lib.mkIf config.services.xray-user.enable {
    home.file.".config/xray/config.example.json" = {
      source = ./config.example.json;
    };
  };
}
