{
  programs.ssh = {
    enable = true;

    matchBlocks = {
      "ubuntu" = {
        hostname = "192.168.1.20";
        user = "romank";
        port = 22;
        extraOptions = {
          "IdentityFile" = "~/.ssh/id_ed25519";
        };
      };

      # Универсальные настройки для всех хостов
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
