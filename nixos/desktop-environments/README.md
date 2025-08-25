# Desktop Environments

Этот каталог содержит модули для различных рабочих окружений.

## Доступные окружения:

### 🖥️ GNOME (`gnome.nix`)
- **Display Manager**: GDM с Wayland
- **Session**: GNOME Desktop Environment 
- **Audio**: PipeWire
- **Features**: 
  - Wayland поддержка
  - XDG portals интеграция
  - OpenGL hardware acceleration
  - Оптимизация пакетов (убраны ненужные GNOME приложения)
  - PAM/Polkit интеграция для безопасности

### 🚀 Hyprland (планируется)
- **Display Manager**: SDDM или LightDM
- **Session**: Hyprland (tiling Wayland compositor)
- **Audio**: PipeWire
- **Features**: Современный tiling window manager

### 🪟 KDE Plasma (планируется)  
- **Display Manager**: SDDM
- **Session**: KDE Plasma Desktop
- **Audio**: PipeWire
- **Features**: Полнофункциональное KDE окружение

## Использование:

### В `configuration.nix` или модулях:

```nix
{
  imports = [
    ./desktop-environments/gnome.nix  # Для GNOME
    # ./desktop-environments/hyprland.nix  # Для Hyprland  
    # ./desktop-environments/kde.nix       # Для KDE
  ];
}
```

### Переключение между окружениями:

1. **Закомментировать текущее** окружение в imports
2. **Раскомментировать нужное** окружение  
3. **Пересобрать систему**: `sudo nixos-rebuild switch`
4. **Перезагрузиться** для смены display manager

## Структура модулей:

Каждый модуль окружения должен содержать:
- ✅ Display Manager конфигурацию
- ✅ Desktop Environment настройки
- ✅ Audio subsystem (PipeWire)
- ✅ Graphics/OpenGL настройки
- ✅ Session variables
- ✅ XDG portals
- ✅ Security settings (PAM, polkit)
- ✅ Package optimization

## Преимущества модульной структуры:

1. **Чистое разделение** - каждое окружение изолировано
2. **Легкое переключение** - один import в configuration.nix
3. **Избежание конфликтов** - настройки не пересекаются
4. **Поддерживаемость** - легко обновлять отдельные окружения
5. **Экспериментирование** - можно тестировать новые окружения

## Совместимость:

Все модули совместимы с:
- ✅ Home Manager конфигурацией
- ✅ NixOS flakes
- ✅ Hardware configurations  
- ✅ Network settings
- ✅ Security settings