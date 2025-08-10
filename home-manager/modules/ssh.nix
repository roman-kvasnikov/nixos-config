{
  programs.ssh = {
    enable = true;

    matchBlocks = {
      # Универсальные настройки для всех хостов
      "*" = {
        extraOptions = {
          # Безопасность
          "HashKnownHosts" = "yes";
          "VisualHostKey" = "yes";
          "StrictHostKeyChecking" = "ask";
        };
      };
    };
  };
}
