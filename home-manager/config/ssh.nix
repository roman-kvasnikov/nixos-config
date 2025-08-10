{config, pkgs, ...}: {
  # Автоматически развернуть SSH ключи в ~/.ssh/ (если они существуют)
  # home.file =
  #   let
  #     keyPath = "../ssh-keys";
  #     # keyPath = "../../home-manager/ssh-keys";
  #     # Функция для создания условного файла
  #     mkSshKey = keyName: {
  #       "${config.home.homeDirectory}/.ssh/${keyName}" = {
  #         source = "${keyPath}/${keyName}";
  #       };
  #     };
  #   in
  #   # Основные ключи (раскомментируйте после создания)
  #   mkSshKey "id_ed25519" //
  #   mkSshKey "id_ed25519.pub" //
  #   # mkSshKey "github_id_ed25519" //
  #   # mkSshKey "github_id_ed25519.pub" //
  #   # mkSshKey "vps_id_ed25519" //
  #   # mkSshKey "vps_id_ed25519.pub" //
  #   {};

  home.file = {
    ".ssh/id_ed25519" = {
      source = builtins.path { path = ./../ssh-keys/id_ed25519; };
    };
    ".ssh/id_ed25519.pub" = {
      source = builtins.path { path = ./../ssh-keys/id_ed25519.pub; };
    };
  };

  # Установить правильные права доступа для SSH ключей
  home.activation.fixSshPermissions = config.lib.dag.entryAfter ["writeBoundary"] ''
    run chmod 700 ${config.home.homeDirectory}/.ssh
    run chmod 600 ${config.home.homeDirectory}/.ssh/id_ed25519 ${config.home.homeDirectory}/.ssh/*_id_ed25519 2>/dev/null || true
    run chmod 644 ${config.home.homeDirectory}/.ssh/*.pub 2>/dev/null || true
  '';
  
  # === SSH CLIENT КОНФИГУРАЦИЯ ===
  programs.ssh = {
    enable = true;
    
    # Конфигурация SSH клиента с разными ключами для разных сервисов
    matchBlocks = {
      # "github.com" = {
      #   hostname = "github.com";
      #   user = "git";
      #   identityFile = "~/.ssh/github_id_ed25519";
      #   extraOptions = {
      #     "AddKeysToAgent" = "yes";
      #   };
      # };

      # Универсальные настройки для всех хостов
      "*" = {
        identityFile = "~/.ssh/id_ed25519";
        extraOptions = {
          # Современные алгоритмы
          "KexAlgorithms" = "curve25519-sha256@libssh.org,diffie-hellman-group16-sha512";
          "Ciphers" = "chacha20-poly1305@openssh.com,aes256-gcm@openssh.com";
          "MACs" = "hmac-sha2-256-etm@openssh.com,hmac-sha2-512-etm@openssh.com";
          
          # Безопасность
          "HashKnownHosts" = "yes";
          "VisualHostKey" = "yes";
          "StrictHostKeyChecking" = "ask";
          
          # Производительность
          "Compression" = "yes";
          "ServerAliveInterval" = "60";
          "ServerAliveCountMax" = "3";

          # Переиспользование соединений
          "ControlMaster" = "auto";
          "ControlPath" = "~/.ssh/master-%r@%h:%p";
          "ControlPersist" = "10m";
        };
      };
    };
  };
}
