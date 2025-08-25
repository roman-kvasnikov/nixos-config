{pkgs, ...}: {
  home.packages = with pkgs; [
    # GNOME Core приложения (если нужны)
    # gnome-tweaks # Дополнительные настройки GNOME
    # dconf-editor # Редактор настроек
    # gnome-extension-manager # Управление расширениями

    # GNOME расширения
    gnomeExtensions.auto-move-windows # Автоматическое перемещение окон
    gnomeExtensions.bitcoin-markets # Криптовалютные курсы
    gnomeExtensions.blur-my-shell # Размытие
    gnomeExtensions.caffeine # Предотвращение блокировки
    gnomeExtensions.clipboard-history # История буфера
    gnomeExtensions.dash-to-dock # Док панель
    gnomeExtensions.just-perfection # Настройки интерфейса
    gnomeExtensions.search-light # Поиск

    # Новые полезные расширения (2025)
    # gnomeExtensions.appindicator # Системные индикаторы
    # gnomeExtensions.vitals # Мониторинг системы
    # gnomeExtensions.gsconnect # Интеграция с Android
    # gnomeExtensions.pop-shell # Тайловый менеджер окон
    # gnomeExtensions.forge # Альтернативный тайловый менеджер
  ];
}
