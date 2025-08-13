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
    components = ["pkcs11" "secrets"]; # Убираем "ssh" компонент
  };

  # Настраиваем переменные окружения для SSH
  # home.sessionVariables = {
  #   # KeePassXC создает socket по умолчанию здесь
  #   SSH_AUTH_SOCK = "$XDG_RUNTIME_DIR/org.keepassxc.KeePassXC.ssh";
  #   # Отключаем SSH компонент GNOME Keyring на уровне переменных окружения
  #   GSM_SKIP_SSH_AGENT_WORKAROUND = "1";
  # };

  # Создаем директорию для socket
  # xdg.configFile."keepassxc/keepassxc.ini" = {
  #   text = ''
  #     [General]
  #     ConfigVersion=2

  #     [Browser]
  #     Enabled=true

  #     [FdoSecrets]
  #     Enabled=true

  #     [GUI]
  #     ApplicationTheme=auto
  #     HideToolbar=false
  #     HideUsernames=false
  #     MinimizeOnClose=true
  #     MinimizeOnStartup=false
  #     MinimizeToTray=true
  #     ShowTrayIcon=true
  #     TrayIconAppearance=monochrome-light

  #     [SSHAgent]
  #     Enabled=true
  #     AuthSockOverride=false
  #     UseSSHKeyDecryption=true

  #     [Security]
  #     ClearClipboard=true
  #     ClearClipboardTimeout=10
  #     IconDownloadFallback=false
  #     LockDatabaseIdle=true
  #     LockDatabaseIdleSeconds=240
  #     LockDatabaseMinimize=false
  #     LockDatabaseScreenLock=true
  #   '';
  # };

  # Создаем systemd сервис для автозапуска KeePassXC в фоновом режиме
  systemd.user.services.keepassxc = {
    Unit = {
      Description = "KeePassXC Password Manager with SSH Agent";
      After = ["graphical-session.target"];
      Wants = ["graphical-session.target"];
    };

    Service = {
      Type = "simple";
      ExecStart = "${pkgs.keepassxc}/bin/keepassxc";
      Restart = "on-failure";
      RestartSec = "5s";

      Environment = [
        "PATH=${pkgs.openssh}/bin:$PATH"
      ];
    };

    Install = {
      WantedBy = ["default.target"];
    };
  };

  # Создаем скрипты для работы с KeePassXC SSH agent
  home.packages = [
    (pkgs.writeShellScriptBin "ssh-agent-status" ''
      echo "SSH_AUTH_SOCK: $SSH_AUTH_SOCK"
      if [ -S "$SSH_AUTH_SOCK" ]; then
        echo "✅ SSH agent socket exists"
        echo "Available SSH keys:"
        ${pkgs.openssh}/bin/ssh-add -l 2>/dev/null || echo "No keys loaded or agent not running"
      else
        echo "❌ SSH agent socket not found at: $SSH_AUTH_SOCK"
        echo "Checking common KeePassXC socket locations:"
        for socket in "/tmp/ssh-*/agent.*" "$XDG_RUNTIME_DIR/org.keepassxc.KeePassXC.ssh" "$XDG_RUNTIME_DIR/keepassxc"*; do
          if [ -S "$socket" ] 2>/dev/null; then
            echo "Found socket at: $socket"
          fi
        done
        echo ""
        echo "To fix:"
        echo "1. Open KeePassXC"
        echo "2. Tools → Settings → SSH Agent → Enable SSH Agent"
        echo "3. Open your database"
        echo "4. Add SSH key to an entry (Advanced tab → Attachments)"
        echo "5. Check 'Add key to SSH Agent when database is opened/unlocked'"
      fi
    '')

    (pkgs.writeShellScriptBin "keepassxc-ssh-setup" ''
      echo "🔧 KeePassXC SSH Agent Setup Guide"
      echo "=================================="
      echo ""
      echo "1. Open KeePassXC GUI application"
      echo "2. Go to: Tools → Settings → SSH Agent"
      echo "3. Check ✅ 'Enable SSH Agent integration'"
      echo "4. Restart KeePassXC or apply settings"
      echo ""
      echo "5. Open your password database"
      echo "6. Create a new entry or edit existing one"
      echo "7. Go to 'Advanced' tab"
      echo "8. Click 'Attachments' → 'Add'"
      echo "9. Attach your SSH private key file (e.g., ~/.ssh/id_ed25519)"
      echo "10. Check ✅ 'Add key to SSH Agent when database is opened/unlocked'"
      echo ""
      echo "After setup, run 'ssh-agent-status' to verify"
    '')
  ];
}
