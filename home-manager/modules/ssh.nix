{
  programs.ssh = {
    enable = true;

    matchBlocks = {
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
