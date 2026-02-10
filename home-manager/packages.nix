{
  inputs,
  system,
  pkgs,
  ...
}: {
  nixpkgs.config = {
    allowUnfree = true;

    permittedInsecurePackages = [
      "googleearth-pro-7.3.6.10201"
      "python3.13-ecdsa-0.19.1"
    ];
  };

  home.packages = with pkgs; [
    # Пользовательские CLI утилиты
    bat # Лучший аналог cat
    bc # Калькулятор
    calc # Расширенный калькулятор
    eza # Современный ls
    glib # Системные библиотеки
    jq # JSON процессор
    claude-code # AI ассистент
    cliphist # История буфера
    wl-clipboard # Wayland clipboard
    fastfetch # Информация о системе
    tree # Показ структуры директорий
    cmatrix # Матрица
    s3fs # S3 файловая система
    yandex-disk # Yandex Disk

    # Дополнительные CLI утилиты (2025 recommendations)
    ripgrep # Быстрый поиск в файлах
    fd # Быстрый find
    dust # Современный du
    duf # Современный df
    procs # Современный ps
    bandwhich # Мониторинг сетевого трафика
    tokei # Подсчет строк кода
    hyperfine # Бенчмарки командной строки
    doggo # Современный dig
    gping # Визуальный ping
    ffmpeg # Видео/аудио обработка
    ffmpegthumbnailer # Превью видео

    # Форматирование Nix кода (перенести в home-manager)
    inputs.alejandra.defaultPackage.${system}

    # Терминалы и shells
    kitty # Современный терминал (должен быть в home)
    warp-terminal # Альтернативный терминал с AI

    # Desktop приложения

    # Офисные приложения
    libreoffice-still # Офисный пакет
    typst # New markup-based typesetting system that is powerful and easy to learn
    evince # PDF viewer
    obsidian # Заметки

    # Графические редакторы
    gimp # Растровая графика
    inkscape # Векторная графика
    krita # Цифровая живопись
    pinta # Простой редактор

    # Видеоредакторы
    # davinci-resolve # Профессиональный видеоредактор
    # kdePackages.kdenlive # Видеоредактор

    # Аудиоредакторы
    tenacity

    # Мультимедиа
    vlc # Универсальный плеер
    telegram-desktop # Telegram
    # discord # Discord
    (callPackage ./modules/whatsapp-electron/whatsapp-electron.nix {}) # WhatsApp
    cassette # Yandex Music
    googleearth-pro # Google Earth
    filebot
    # nextcloud-client # Nextcloud клиент

    # AI assistants
    # (callPackage ./modules/claude-electron/claude-electron.nix {}) # Claude AI assistant
    # (callPackage ./modules/deepseek-electron/deepseek-electron.nix {}) # DeepSeek AI assistant

    # Веб и разработка
    postman # API тестирование
    # dbeaver-bin # DB клиент
    tableplus # DB клиент
    filezilla # FTP клиент
    firefox

    # Финансы и криптовалюты
    # electrum # Bitcoin кошелек
    exodus # Crypto кошелек

    # Системные утилиты (для пользователя)

    # Мониторинг (дополнительно к системным)
    iotop # I/O мониторинг
    nethogs # Сетевой мониторинг по процессам

    # Файловые системы и диски
    # gparted # Разметка дисков

    # Современные замены классическим утилитам

    # Текстовые редакторы
    micro # Современный nano

    # Системная информация
    cpufetch # CPU информация
    ramfetch # RAM информация
  ];
}
