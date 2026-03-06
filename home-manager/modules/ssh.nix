{
  programs.ssh = {
    enable = true;

    enableDefaultConfig = false;

    matchBlocks = {
      "homelab-entrypoint" = {
        hostname = "77.232.136.6";
        port = 12122;
        user = "super";
      };

      "xray" = {
        hostname = "192.168.1.3";
        user = "root";
      };

      "traefik" = {
        hostname = "192.168.1.15";
        user = "root";
      };

      "homelab" = {
        hostname = "192.168.1.20";
        user = "romank";
      };

      "homelab-backup" = {
        hostname = "192.168.1.11";
        user = "romank";
      };

      "work" = {
        hostname = "192.168.1.40";
        user = "romank";
      };

      "*" = {
        extraOptions = {
          # Безопасность
          "HashKnownHosts" = "yes";
          "VisualHostKey" = "yes";
          "StrictHostKeyChecking" = "ask";

          # Производительность
          "Compression" = "yes";
          "ServerAliveInterval" = "60";

          # Переиспользование соединений
          "ControlMaster" = "auto";
          "ControlPersist" = "10m";
        };
      };
    };
  };
}
