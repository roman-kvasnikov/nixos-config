# Home Manager Desktop Environments Migration Guide

## 🎯 Что сделано

Создана модульная система для управления desktop environments в Home Manager, которая дополняет существующую NixOS модульную систему и позволяет легко управлять пользовательскими настройками для различных рабочих окружений.

## 📁 Новая структура Home Manager

```
home-manager/
├── desktop-environments/
│   ├── gnome.nix           # Полная конфигурация GNOME (Home Manager)
│   ├── hyprland.nix        # Шаблон для Hyprland (в разработке)
│   └── README.md          # Документация по окружениям
├── config/
│   ├── desktop.nix        # Селектор активного окружения (новый)
│   ├── default.nix        # Существующий файл (не изменен)
│   ├── gtk.nix           # Существующий файл (не изменен)
│   └── xdg.nix           # Существующий файл (не изменен)
└── modules/
    ├── dconf/            # Существующие модули (не изменены)
    ├── stylix.nix        # Существующий модуль (не изменен)
    └── ... (другие модули)
```

## 🖥️ GNOME Home Manager конфигурация

В новом `home-manager/desktop-environments/gnome.nix` собраны **ВСЕ** GNOME-специфичные настройки пользователя:

### 📋 dconf настройки:
- ✅ **Импорт существующих модулей**: `../modules/dconf` (все настройки остаются)
- ✅ **GNOME Shell**: расширения, keybindings, interface
- ✅ **Mutter**: window manager настройки
- ✅ **Desktop**: session, input-sources, app-folders
- ✅ **Shell extensions**: dash-to-dock, auto-move-windows, just-perfection

### 🎨 Темы и стилизация:
- ✅ **GTK3 bookmarks**: интеграция с Files/Nautilus
- ✅ **Stylix GNOME target**: унифицированная тематизация
- ✅ **Шрифты**: Ubuntu Nerd Font family для GNOME
- ✅ **Темная тема**: GTK_THEME и прозрачность

### 🔗 XDG интеграция:
- ✅ **MIME ассоциации**: для всех типов файлов с GNOME приложениями
- ✅ **Пользовательские директории**: Desktop, Documents, Downloads, etc.
- ✅ **Файловые диалоги**: интеграция с GNOME

### 📦 GNOME приложения:
- ✅ **Системные утилиты**: gnome-tweaks, dconf-editor
- ✅ **Расширения**: все необходимые GNOME Shell extensions
- ✅ **Темы**: дополнительные GTK темы и иконки

### 🔧 Environment и сервисы:
- ✅ **GTK variables**: GTK_THEME, GDK_BACKEND, CLUTTER_BACKEND
- ✅ **GNOME Keyring**: полная интеграция с системой
- ✅ **Wayland оптимизации**: для GNOME приложений

## 🚀 Hyprland шаблон (планируется)

В `hyprland.nix` создан детальный шаблон будущей конфигурации:

### 🪟 Window Manager:
- `wayland.windowManager.hyprland` конфигурация
- Keybindings и правила окон
- Workspaces и мониторы

### 📊 Панели и утилиты:
- `programs.waybar` - статус-бар
- `programs.wofi` - application launcher
- `services.mako` - уведомления
- `programs.swaylock` - блокировка экрана

### 🛠️ Wayland утилиты:
- Screenshot tools (grim, slurp, swappy)
- Clipboard management (wl-clipboard)
- Screen recording (wf-recorder)
- Media controls (playerctl)

## 🔄 Архитектура и преимущества

### 🎯 **Двухуровневая система**:

#### NixOS уровень (`nixos/desktop-environments/`):
- Системные службы (GDM, audio, graphics)
- Display managers и window managers
- Hardware acceleration и драйверы
- System-wide интеграция

#### Home Manager уровень (`home-manager/desktop-environments/`):
- Пользовательские настройки и темы
- Приложения и расширения  
- Personal configuration (dconf, gtk)
- User-specific integration

### 🔄 **Синхронизированное переключение**:
```bash
# NixOS уровень
# nixos/modules/desktop.nix
imports = [ ../desktop-environments/gnome.nix ];

# Home Manager уровень  
# home-manager/config/desktop.nix
imports = [ ../desktop-environments/gnome.nix ];
```

### ✨ **Преимущества архитектуры**:
- **Полная изоляция**: каждое DE полностью независимо
- **Синхронизация**: system + user настройки работают вместе
- **Модульность**: легко добавлять новые окружения
- **Чистота**: нет конфликтов между настройками

## 📝 Важные заметки

### ⚠️ Существующие файлы НЕ изменены:
- **`modules/dconf/`** - все настройки GNOME сохранены
- **`modules/stylix.nix`** - существующая конфигурация
- **`config/gtk.nix`** - оригинальные GTK настройки
- **`packages.nix`** - существующие пакеты
- **Все остальные модули** остались без изменений

### ✅ Новая система дополняет существующую:
- Можно использовать параллельно со старой конфигурацией
- Постепенная миграция без поломок
- Обратная совместимость гарантирована

## 🧪 Тестирование и миграция

### Этап 1: Тестирование (текущий)
```nix
# В home.nix добавить дополнительно:
imports = [
  ./config/desktop.nix  # Новый модуль
  # ... существующие imports остаются
];
```

### Этап 2: Полная миграция (опционально)
```nix
# Заменить существующие imports на:
imports = [
  ./config/desktop.nix  # Включает все необходимое
  # Убрать старые dconf, stylix, gtk imports
];
```

## 🔮 Планы развития

### ✨ Ближайшие цели:
1. **Тестирование GNOME модуля** с существующей конфигурацией
2. **Полная реализация Hyprland** модуля
3. **Создание KDE Plasma** модуля
4. **Интеграция с NixOS** desktop-environments

### 🚀 Долгосрочные планы:
- **Тематическая синхронизация** между NixOS и Home Manager
- **Автоматический выбор** оптимальных настроек
- **Plugin система** для расширений
- **GUI инструменты** для переключения окружений

## 🛠️ Как использовать

### Для существующих пользователей GNOME:
1. Система продолжит работать без изменений
2. Можно добавить `config/desktop.nix` для тестирования
3. Постепенно мигрировать настройки
4. Полная замена по желанию

### Для новых установок:
1. Использовать `desktop.nix` селекторы
2. Выбрать желаемое окружение в одном месте
3. Все настройки применятся автоматически
4. Легко переключаться между DE

Эта архитектура создает foundation для поддержки множественных desktop environments с чистым разделением системных и пользовательских настроек! 🎯