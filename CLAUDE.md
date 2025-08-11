# CLAUDE.md

Это персональная конфигурация NixOS с использованием flakes и home-manager для создания современной, безопасной и производительной desktop системы.

## Обзор

**Основные технологии:**
- NixOS Flakes для воспроизводимых сборок
- Home Manager для пользовательских конфигураций
- GNOME + Wayland + PipeWire для современного desktop
- Stylix для унифицированной тематизации
- LUKS + LVM для шифрования дисков

**Каналы:** nixos-unstable и home-manager master для получения последних возможностей

## Архитектура проекта

### Структура файлов

```
nixos-config/
├── flake.nix              # Входные точки, зависимости
├── shared.nix             # Общие настройки хостов
├── hosts/                 # Конфигурации хостов
│   ├── nixos/            # Основной компьютер (LUKS+LVM)
│   └── nixos-vm/         # Виртуальная машина
├── nixos/                # Системные модули
│   ├── modules/          # Модульная система
│   └── packages.nix      # Системные пакеты + исключения GNOME
└── home-manager/         # Пользовательская среда
    ├── modules/          # Модули приложений
    ├── config/           # Базовые настройки
    └── [файлы конфигурации]
```

### Модульная система NixOS

- `boot.nix` - systemd-boot, zen kernel, оптимизации
- `services.nix` - GNOME/Wayland, PipeWire, display manager
- `nix.nix` - настройки Nix, binary cache, оптимизации
- `networking.nix` - DNS, DNSSEC, сетевые оптимизации
- `fonts.nix` - системные шрифты
- `ssh.nix` - SSH клиент (сервер отключен для безопасности)

### Пользовательские модули (Home Manager)

- `dconf/` - настройки GNOME (интерфейс, расширения, клавиши)
- `stylix.nix` - унифицированная тематизация
- `brave/` - браузер с корпоративными политиками
- `xrayctl/` - кастомная система управления прокси
- `git.nix` - конфигурация Git
- `kitty.nix` - терминал
- `fastfetch/` - информация о системе

## Хосты

### nixos (основной компьютер)
- **Безопасность:** LUKS шифрование, SSH отключен
- **Диски:** EFI + LUKS(crypted) → LVM(nixos-vg) → swap(8G) + root(60G) + home(остальное)
- **Оптимизация:** Linux Zen kernel, SSD оптимизации

### nixos-vm (виртуальная машина)
- **Простота:** EFI + swap + btrfs root
- **VM интеграция:** QEMU Guest Agent, SPICE, SSH включен
- **Легковесность:** Облегченная конфигурация

## Основные команды

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

### Управление flake
```bash
# Форматирование кода (обязательно перед коммитом)
alejandra .

# Проверка flake
nix flake check

# Обновление зависимостей
nix flake update

# Сборка без применения
nixos-rebuild build --flake .#nixos
```

### Управление Xray прокси
```bash
# Включение всех прокси
xrayctl all-on

# Выключение всех прокси
xrayctl all-off

# Статус сервиса
systemctl --user status xrayctl
```

### Git операции
```bash
# Синхронизация Obsidian vault
git-sync-obsidian

# При home-manager switch автоматически:
# - Клонируется obsidian-vault репозиторий (если не существует)
# - Обновляется через git pull (если уже существует)
```

## Ключевые особенности

### Система тематизации (Stylix)
- **Wallpaper:** Коллекция из `github:roman-kvasnikov/wallpapers`
- **Шрифты:** Ubuntu Nerd Font (serif, sans-serif, monospace)
- **Тема:** default-dark с темной полярностью
- **Охват:** Терминал, браузер, GNOME, приложения

### GNOME расширения
- `auto-move-windows` - автоперемещение окон
- `bitcoin-markets` - криптокурсы в панели  
- `blur-my-shell` - размытие интерфейса
- `caffeine` - предотвращение блокировки
- `clipboard-history` - история буфера
- `dash-to-dock` - док-панель
- `just-perfection` - тонкие настройки UI
- `search-light` - улучшенный поиск

### Безопасность
- **Шифрование:** LUKS для всего диска + случайное шифрование swap
- **SSH:** Отключен на основном хосте, только исходящие подключения
- **DNS:** systemd-resolved + DNSSEC + Cloudflare
- **Пакеты:** Минимальный набор системных пакетов

### Производительность
- **Ядро:** Linux Zen для desktop производительности
- **Загрузчик:** systemd-boot (быстрее GRUB)
- **Аудио:** PipeWire + низкая задержка
- **Nix:** Множественные binary cache, использование всех ядер
- **Сеть:** BBR congestion control, CAKE qdisc
- **SSD:** Оптимизированные планировщики I/O

### Управление пакетами
- **Системно:** Только базовые утилиты, CLI инструменты
- **Home Manager:** Desktop приложения, разработка, мультимедиа
- **GNOME:** Максимальная очистка от ненужных приложений

## Development Workflow

1. Внести изменения в соответствующие `.nix` файлы
2. Отформатировать код: `alejandra .`
3. Проверить flake: `nix flake check`
4. Применить изменения:
   - Система: `sudo nixos-rebuild switch --flake .#nixos`
   - Пользователь: `home-manager switch --flake .#romank@nixos`
5. При изменениях ядра/загрузчика - перезагрузка
6. Коммит и push изменений

## State Management

- **State Version:** `25.05` (синхронизирован между system и home)
- **Сборка мусора:** Ежедневно, хранение 7 дней, лимит 20 поколений
- **Оптимизация:** Автоматическая оптимизация Nix store
- **Исключения GNOME:** Удалены ненужные приложения для экономии места

## Inputs и зависимости

### Основные
- `nixpkgs`: `github:nixos/nixpkgs/nixos-unstable`
- `home-manager`: `github:nix-community/home-manager/master`
- `stylix`: `github:nix-community/stylix/master`

### Утилиты
- `alejandra`: v4.0.0 (Nix форматтер)

### Персональные репозитории
- `wallpapers`: `github:roman-kvasnikov/wallpapers`
- `obsidian-vault`: `git@github.com:roman-kvasnikov/obsidian-vault.git`

## Специальные возможности

### SSH ключи (Home Manager)
- Автоматическое развертывание в `~/.ssh/`
- Конфигурация SSH клиента с различными ключами для разных сервисов
- Современные алгоритмы шифрования и сжатия

### XrayCtl прокси система
- Systemd сервис для управления прокси
- JSON конфигурация с multiple endpoints
- Shell команды для быстрого переключения
- GNOME расширение для GUI управления (в разработке)

### Obsidian интеграция  
- Автоматическое клонирование репозитория при развертывании
- Systemd timer для автоматической синхронизации каждые 15 минут
- Команда `git-sync-obsidian` для ручной синхронизации

## Последние обновления (Февраль 2025)

### Переход на unstable каналы
- ✅ nixos-unstable для получения последних возможностей
- ✅ home-manager master для современных опций
- ✅ stylix master для новейших функций тематизации

### Структурные улучшения
- ✅ Создан shared.nix для общих настроек хостов
- ✅ Модульная архитектура с четким разделением ответственности
- ✅ Оптимизированная конфигурация служб для unstable

### Безопасность и производительность
- ✅ LUKS + LVM с оптимизациями для SSD
- ✅ Множественные binary cache для быстрых сборок
- ✅ Агрессивная сборка мусора и оптимизация store
- ✅ Современные сетевые протоколы и оптимизации

Эта конфигурация представляет современную, безопасную и высокопроизводительную NixOS систему, оптимизированную для desktop использования с акцентом на разработку и повседневные задачи.