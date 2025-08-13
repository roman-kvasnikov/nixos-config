{
  config,
  lib,
  pkgs,
  ...
}: {
  programs.ssh = {
    enable = true;

    # Глобальные настройки SSH клиента
    extraConfig = ''
      # Используем KeePassXC SSH Agent
      IdentityAgent $SSH_AUTH_SOCK

      # Безопасность
      StrictHostKeyChecking ask
      VerifyHostKeyDNS yes
      HashKnownHosts yes

      # Оптимизация подключения
      Compression yes
      ServerAliveInterval 60
      ServerAliveCountMax 3
      TCPKeepAlive yes

      # Современные алгоритмы шифрования
      KexAlgorithms curve25519-sha256,curve25519-sha256@libssh.org,diffie-hellman-group16-sha512,diffie-hellman-group18-sha512
      HostKeyAlgorithms ssh-ed25519,ecdsa-sha2-nistp256,ecdsa-sha2-nistp384,ecdsa-sha2-nistp521,rsa-sha2-512,rsa-sha2-256
      Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,aes192-ctr,aes128-ctr
      MACs hmac-sha2-256-etm@openssh.com,hmac-sha2-512-etm@openssh.com,umac-128-etm@openssh.com
    '';

    # Примеры хостов (можете настроить под свои нужды)
    matchBlocks = {
      # Пример для других серверов
      # "myserver" = {
      #   hostname = "example.com";
      #   user = "username";
      #   port = 22;
      # };
    };
  };

  # Устанавливаем SSH утилиты
  home.packages = with pkgs; [
    openssh
  ];
}
