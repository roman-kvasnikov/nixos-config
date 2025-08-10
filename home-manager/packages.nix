{pkgs, ...}: {
  home.packages = with pkgs; [
    # Пользовательские CLI утилиты
    bat # Лучший аналог cat
    bc # Калькулятор
    calc # Расширенный калькулятор
    jq # JSON процессор
    glib # Системные библиотеки
    claude-code # AI ассистент
    cliphist # История буфера
    wl-clipboard # Wayland clipboard
    eza # Современный ls
    fastfetch # Информация о системе
    ffmpeg # Видео/аудио обработка
    ffmpegthumbnailer # Превью видео
    silicon # Красивые скриншоты кода
    tree # Показ структуры директорий
    xray # Proxy tool

    # Дополнительные CLI утилиты (2025 recommendations)
    s3fs # Mount an S3 bucket as filesystem through FUSE
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

    # Терминалы и shells
    kitty # Современный терминал (должен быть в home)
    warp-terminal # Альтернативный терминал

    # Desktop приложения

    # Офисные приложения
    libreoffice-still # Офисный пакет
    evince # PDF viewer (лучше встроенного в GNOME)
    obsidian # Заметки
    keepassxc # Менеджер паролей

    # Графические редакторы (современные версии)
    gimp # Растровая графика
    inkscape # Векторная графика
    krita # Цифровая живопись
    pinta # Простой редактор

    # Мультимедиа
    vlc # Универсальный плеер
    telegram-desktop # Мессенджер
    vesktop # Discord

    # Веб и разработка
    postman # API тестирование
    filezilla # FTP клиент

    # Финансы и криптовалюты
    electrum # Bitcoin кошелек
    # exodus - закомментирован (нестабильный)

    # === GNOME ИНТЕГРАЦИЯ ===

    # Основные GNOME утилиты (должны быть в home для пользователя)
    # gnome-tweaks # Настройки GNOME
    # gnome-extension-manager # Управление расширениями
    # dconf-editor # Редактор настроек

    # GNOME EXTENSIONS (2025 рекомендации)
    gnomeExtensions.bitcoin-markets # Криптовалютные курсы
    gnomeExtensions.blur-my-shell # Размытие
    gnomeExtensions.caffeine # Предотвращение блокировки
    gnomeExtensions.clipboard-history # История буфера
    gnomeExtensions.dash-to-dock # Док панель
    gnomeExtensions.just-perfection # Настройки интерфейса
    gnomeExtensions.search-light # Поиск
    gnomeExtensions.user-themes # Темы

    # Новые полезные расширения (2025)
    # gnomeExtensions.appindicator # Системные индикаторы
    # gnomeExtensions.vitals # Мониторинг системы
    # gnomeExtensions.gsconnect # Интеграция с Android
    # gnomeExtensions.pop-shell # Тайловый менеджер окон
    # gnomeExtensions.forge # Альтернативный тайловый менеджер

    # Системные утилиты (для пользователя)

    # Мониторинг (дополнительно к системным)
    bottom # Современный top
    iotop # I/O мониторинг
    nethogs # Сетевой мониторинг по процессам

    # Файловые системы и диски
    # gparted # Разметка дисков
    gnome-disk-utility # Утилита дисков GNOME

    # Современные замены классическим утилитам

    # Текстовые редакторы
    micro # Современный nano

    # Системная информация
    cpufetch # CPU информация
    ramfetch # RAM информация
  ];
}
