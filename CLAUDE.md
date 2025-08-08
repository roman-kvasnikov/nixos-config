# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Это персональная конфигурация NixOS с использованием flakes и home-manager. Система поддерживает два хоста: `nixos` и `nixos-vm` для основного компьютера и виртуальной машины соответственно.

## Common Commands

### Применение конфигурации системы
```bash
sudo nixos-rebuild switch --flake .#nixos
# Или для VM:
sudo nixos-rebuild switch --flake .#nixos-vm
```

### Применение home-manager конфигурации
```bash
home-manager switch --flake .#romank@nixos
# Или для VM:
home-manager switch --flake .#romank@nixos-vm
```

### Форматирование Nix-кода
```bash
# Используется alejandra форматтер (включен в flake.nix)
alejandra .
```

### Проверка flake
```bash
nix flake check
```

### Обновление зависимостей
```bash
nix flake update
```

### Сборка без применения изменений
```bash
nixos-rebuild build --flake .#nixos
```

## Architecture

### Структура проекта

- `flake.nix` - главный файл flake с входными точками и конфигурацией хостов
- `hosts/` - специфические конфигурации для каждого хоста
  - `nixos/` - конфигурация основного компьютера
  - `nixos-vm/` - конфигурация виртуальной машины
- `nixos/` - общие модули NixOS системы
  - `modules/` - модульная конфигурация системы (boot, networking, services, etc.)
  - `packages.nix` - системные пакеты и исключения GNOME
- `home-manager/` - конфигурация пользовательского окружения
  - `home.nix` - основной файл home-manager
  - `home-packages.nix` - пользовательские пакеты
  - `home-configs.nix` - конфигурации XDG и GTK
  - `modules/` - модули приложений (brave, git, kitty, etc.)

### Ключевые особенности

- **Flakes**: Используется экспериментальная функция flakes для воспроизводимых сборок
- **Home Manager**: Управление пользовательскими пакетами и конфигурациями
- **Stylix**: Унифицированная тематизация всей системы
- **GNOME**: Основная рабочая среда с настроенными расширениями
- **Модульная архитектура**: Каждый аспект системы вынесен в отдельные модули

### Управление состоянием

- `system.stateVersion` и `home.stateVersion` синхронизированы с версией NixOS
- Используется автоматическая оптимизация и сборка мусора Nix
- Исключены ненужные приложения GNOME для экономии места

### Пользовательские репозитории

- `wallpapers` - коллекция обоев (github:roman-kvasnikov/wallpapers)
- `vscode-settings` - настройки VS Code (github:roman-kvasnikov/vscode-settings)

## Development Workflow

1. Внести изменения в соответствующие `.nix` файлы
2. Отформатировать код с помощью `alejandra .`
3. Проверить flake с помощью `nix flake check`
4. Применить изменения через `nixos-rebuild` или `home-manager switch`
5. При необходимости перезагрузиться для изменений ядра/загрузчика

## Последние Оптимизации

Конфигурация была оптимизирована согласно NixOS best practices 2025:

### Исправлены критические проблемы:
- ✅ Исправлена опечатка `grp:ctrl_shift_toogle` → `grp:ctrl_shift_toggle`
- ✅ Убрано дублирование настроек клавиатуры (теперь только в dconf)
- ✅ Консолидировано управление шрифтами через stylix

### Структурные улучшения:
- ✅ Создан `shared.nix` для общих настроек хостов
- ✅ Очищены неиспользуемые закомментированные модули
- ✅ Активирован Brave browser (был закомментирован)

### Performance оптимизации:
- ✅ Сборка мусора изменена с 30d на 1w для экономии места
- ✅ Добавлен лимит в 10 generations
- ✅ Настроен nix-community binary cache
- ✅ Включено использование всех доступных ядер для сборки
- ✅ Оптимизированы настройки Nix store

### Архитектурные улучшения:
- ✅ Убрано дублирование шрифтов между system и stylix
- ✅ Упрощена структура flake.nix с использованием shared.nix
- ✅ Очищен код от устаревших закомментированных блоков