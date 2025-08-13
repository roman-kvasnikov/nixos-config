{
  config,
  lib,
  pkgs,
  ...
}: {
  # KeePassXC уже включен в packages.nix

  # Отключаем стандартный ssh-agent если используем KeePassXC
  services.ssh-agent.enable = lib.mkForce false;
  
  # Отключаем SSH компонент GNOME Keyring чтобы избежать конфликтов
  services.gnome-keyring = {
    enable = true;
    components = [ "pkcs11" "secrets" ]; # Убираем "ssh" компонент
  };

  # Настраиваем переменные окружения для SSH
  home.sessionVariables = {
    SSH_AUTH_SOCK = "$XDG_RUNTIME_DIR/keepassxc/ssh_socket";
    # Отключаем SSH компонент GNOME Keyring на уровне переменных окружения
    GSM_SKIP_SSH_AGENT_WORKAROUND = "1";
  };

  # Создаем директорию для socket
  xdg.configFile."keepassxc/keepassxc.ini" = {
    text = ''
      [General]
      ConfigVersion=2

      [Browser]
      Enabled=true
      
      [FdoSecrets]
      Enabled=true

      [GUI]
      ApplicationTheme=auto
      HideToolbar=false
      HideUsernames=false
      MinimizeOnClose=true
      MinimizeOnStartup=false
      MinimizeToTray=true
      ShowTrayIcon=true
      TrayIconAppearance=monochrome-light

      [SSHAgent]
      Enabled=true
      AuthSockOverride=true
      UseSSHKeyDecryption=true

      [Security]
      ClearClipboard=true
      ClearClipboardTimeout=10
      IconDownloadFallback=false
      LockDatabaseIdle=true
      LockDatabaseIdleSeconds=240
      LockDatabaseMinimize=false
      LockDatabaseScreenLock=true
    '';
  };

  # Создаем systemd сервис для автозапуска KeePassXC в фоновом режиме
  systemd.user.services.keepassxc = {
    Unit = {
      Description = "KeePassXC Password Manager with SSH Agent";
      After = [ "graphical-session.target" ];
      Wants = [ "graphical-session.target" ];
    };

    Service = {
      Type = "simple";
      ExecStart = "${pkgs.keepassxc}/bin/keepassxc";
      Restart = "on-failure";
      RestartSec = "5s";
      
      Environment = [
        "PATH=${pkgs.openssh}/bin:$PATH"
        "SSH_AUTH_SOCK=%t/keepassxc/ssh_socket"
      ];
    };

    Install = {
      WantedBy = [ "default.target" ];
    };
  };

  # Создаем скрипт для проверки статуса SSH агента
  home.packages = [
    (pkgs.writeShellScriptBin "ssh-agent-status" ''
      echo "SSH_AUTH_SOCK: $SSH_AUTH_SOCK"
      if [ -S "$SSH_AUTH_SOCK" ]; then
        echo "✅ SSH agent socket exists"
        echo "Available SSH keys:"
        ${pkgs.openssh}/bin/ssh-add -l 2>/dev/null || echo "No keys loaded or agent not running"
      else
        echo "❌ SSH agent socket not found"
        echo "Make sure KeePassXC is running with SSH agent enabled"
      fi
    '')
  ];
}