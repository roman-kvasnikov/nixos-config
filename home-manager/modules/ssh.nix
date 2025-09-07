{
  programs.ssh = {
    enable = true;

    enableDefaultConfig = false;

    matchBlocks = {
      "nas" = {
        hostname = "192.168.1.1";
        user = "RomanK";
      };

      "ubuntu" = {
        hostname = "192.168.1.20";
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
