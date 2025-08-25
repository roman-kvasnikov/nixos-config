# Home Manager Desktop Environments

Этот каталог содержит модули Home Manager для различных рабочих окружений.

## Доступные окружения:

### 🖥️ GNOME (`gnome.nix`)
**Статус**: ✅ Полностью реализовано

**Компоненты**:
- **dconf настройки**: Полная конфигурация GNOME Shell, Mutter, расширений
- **GTK интеграция**: Bookmarks, темы, настройки приложений
- **Stylix интеграция**: Унифицированные темы для GNOME
- **XDG настройки**: MIME ассоциации, пользовательские директории
- **GNOME приложения**: Tweaks, dconf-editor, расширения
- **Environment variables**: GTK/Wayland оптимизации
- **GNOME services**: Keyring, уведомления

**Расширения GNOME**:
- Dash to Dock - док-панель
- Auto Move Windows - автоперемещение окон
- Just Perfection - тонкие настройки UI
- Caffeine - предотвращение блокировки
- Blur My Shell - размытие интерфейса
- Clipboard History - история буфера
- Search Light - улучшенный поиск
- Bitcoin Markets - криптокурсы в панели

### 🚀 Hyprland (`hyprland.nix`)
**Статус**: 🚧 В разработке (шаблон создан)

**Планируемые компоненты**:
- **Hyprland WM**: Window manager конфигурация
- **Waybar**: Статус-бар с модулями
- **Wofi**: Application launcher
- **Mako**: Система уведомлений
- **Swaylock**: Экран блокировки
- **Утилиты**: Screenshot tools, clipboard, media controls

### 🪟 KDE Plasma (планируется)
**Статус**: 📋 Запланировано

**Планируемые компоненты**:
- Plasma desktop настройки
- KDE приложения интеграция
- Konsole конфигурация
- Dolphin настройки

## Использование:

### В `home.nix` или модулях:

```nix
{
  imports = [
    ./desktop-environments/gnome.nix     # Для GNOME
    # ./desktop-environments/hyprland.nix  # Для Hyprland  
    # ./desktop-environments/kde.nix       # Для KDE
  ];
}
```

### Создание селектора (рекомендуется):

Создать файл `home-manager/config/desktop.nix`:

```nix
{
  # =============================================================================
  # DESKTOP ENVIRONMENT SELECTION - HOME MANAGER
  # =============================================================================
  
  imports = [
    # Выбрать ОДНО рабочее окружение:
    
    # 🖥️ GNOME (текущее)
    ../desktop-environments/gnome.nix
    
    # 🚀 Hyprland (в разработке)  
    # ../desktop-environments/hyprland.nix
    
    # 🪟 KDE Plasma (планируется)
    # ../desktop-environments/kde.nix
  ];
}
```

## Архитектура модулей:

### GNOME модуль включает:

#### 📋 dconf настройки (через импорт):
- `../modules/dconf` - полная dconf конфигурация
  - Desktop настройки (interface, session, input-sources)
  - Shell настройки (extensions, weather, world-clocks)
  - Keybindings и mutter конфигурация

#### 🎨 Темы и стили:
- GTK3 bookmarks для Files/Nautilus
- Stylix интеграция с GNOME target
- Шрифты Ubuntu Nerd Font family
- Темная тема и прозрачность

#### 🔗 XDG интеграция:
- MIME ассоциации для всех типов файлов
- Пользовательские директории XDG
- Интеграция с GNOME приложениями

#### 📦 Пакеты и приложения:
- GNOME Tweaks и dconf-editor
- Все необходимые GNOME Shell расширения
- GTK темы и иконки

#### 🔧 Environment и сервисы:
- GTK_THEME, GDK_BACKEND настройки
- GNOME Keyring интеграция
- Wayland оптимизации для GNOME

### Hyprland модуль (планируется):

#### 🪟 Window Manager:
```nix
wayland.windowManager.hyprland = {
  enable = true;
  settings = {
    # Полная конфигурация Hyprland
  };
};
```

#### 📊 Статус-бар:
```nix
programs.waybar = {
  enable = true;
  # Настройки и стили
};
```

#### 🚀 Утилиты:
- Application launcher (wofi)
- Notifications (mako)
- Screen lock (swaylock)
- Screenshots (grim/slurp)

## Преимущества модульной структуры:

### 🎯 **Изоляция настроек**:
- Каждое DE имеет свой независимый набор настроек
- Нет конфликтов между различными окружениями
- Легко переключаться без остаточных настроек

### 🔄 **Простое переключение**:
- Один import для активации окружения
- Все настройки применяются автоматически
- Чистая активация без ручной настройки

### 🛠️ **Поддерживаемость**:
- Четкое разделение компонентов
- Легко добавлять новые функции
- Простое обслуживание и обновления

### 🧪 **Экспериментирование**:
- Безопасное тестирование новых окружений
- Быстрый rollback к рабочей конфигурации
- A/B тестирование различных настроек

## Совместимость:

### ✅ С NixOS модулями:
- Работает с любым NixOS desktop environment
- Дополняет системные настройки
- Не конфликтует с system-level конфигурацией

### ✅ С Home Manager:
- Совместимо со всеми Home Manager модулями
- Интегрируется с packages.nix
- Работает с services.nix

### ✅ С существующими настройками:
- Можно постепенно мигрировать
- Существующие настройки не затрагиваются
- Обратная совместимость сохранена

## Миграция:

### Текущие пользователи GNOME:
1. Система продолжит работать как раньше
2. Все настройки остаются в существующих модулях
3. Новый модуль можно включить дополнительно
4. После тестирования - заменить старые imports

### Для новых пользователей:
1. Включить нужный desktop environment модуль
2. Все настройки применятся автоматически
3. Настроить специфичные для окружения параметры