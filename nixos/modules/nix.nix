{pkgs, ...}: {
  nix = {
    # Автоматическая оптимизация store
    optimise = {
      automatic = true;
      dates = ["03:45"]; # Оптимизация рано утром
    };

    # Сборка мусора
    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 7d";
      randomizedDelaySec = "1h"; # Случайная задержка для SSD
    };

    settings = {
      # Производительность
      auto-optimise-store = true;
      experimental-features = [
        "nix-command" 
        "flakes"
        "ca-derivations"    # Content-addressed derivations (2025)
        "fetch-closure"     # Closure fetching optimization
        "recursive-nix"     # Recursive nix builds
      ];
      
      # Максимальная производительность сборки
      cores = 0; # Использовать все ядра
      max-jobs = "auto";
      
      # Параллельные загрузки (2025 optimization)
      http-connections = 25;
      max-substitution-jobs = 16;

      # Binary cache
      substituters = [
        "https://cache.nixos.org/"
        "https://nix-community.cachix.org"
        "https://cuda-maintainers.cachix.org" # Для CUDA пакетов если нужно
        "https://devenv.cachix.org"           # Для development environments
      ];

      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "cuda-maintainers.cachix.org-1:0dq3bujKpuEPiCgBV2hsd2nyMhcg0QKCBVzSjUH4SLQ="
        "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU/KJQ="
      ];

      # Безопасность и производительность

      # Доверенные пользователи
      trusted-users = ["root" "@wheel"];

      # Современные feature flags
      system-features = [
        "nixos-test"
        "benchmark"
        "big-parallel" 
        "kvm" # Для VM тестирования
      ];

      # Оптимизация для SSD
      fsync-metadata = false;

      # Параллельная сборка
      builders-use-substitutes = true;

      # Логирование (минимальное)
      log-lines = 10;

      # Оптимизация памяти
      max-free = 3 * 1024 * 1024 * 1024; # 3GB
      min-free = 1024 * 1024 * 1024;     # 1GB
      
      # Оптимизация сети
      connect-timeout = 10;
      stalled-download-timeout = 300;
    };

    # Дополнительные настройки для 2025
    extraOptions = ''
      # Ускорение сборки за счет меньших проверок
      builders-use-substitutes = true

      # Оптимизация сети
      http2 = true

      # Предварительная загрузка зависимостей
      pre-build-hook = ${pkgs.writeScript "pre-build-hook" ''
        #!/bin/sh
        echo "Starting build of $1"
      ''}
    '';

    # Registry для flakes (2025 best practice)
    # registry = {
    #   nixpkgs.flake = pkgs.path;
    #   templates.flake = "github:NixOS/templates";
    # };

    # Nixpkgs конфигурация
    nixPath = [
      "nixpkgs=${pkgs.path}"
    ];
  };
}
