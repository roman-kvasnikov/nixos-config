#!/usr/bin/env bash

# Строгий режим для bash
set -euo pipefail
IFS=$'\n\t'

# =============================================================================
# КОНСТАНТЫ И КОНФИГУРАЦИЯ
# =============================================================================

# Основные пути
readonly BUILDIN_MONITOR="@buildinMonitor@"

# Цвета для вывода (ANSI escape codes)
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly WHITE='\033[1;37m'
readonly NC='\033[0m' # No Color

# =============================================================================
# УТИЛИТЫ ДЛЯ ВЫВОДА
# =============================================================================

print_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_info() {
    echo -e "${BLUE}[i]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1" >&2
}

print_header() {
    echo -e "${PURPLE}$1${NC}"
}

print_status() {
    echo -e "${CYAN}$1${NC}"
}

# =============================================================================
# ВАЛИДАЦИЯ И ПРОВЕРКИ
# =============================================================================

# Проверить, что скрипт запущен не от root
check_user() {
    if [ "$(id -u)" -eq 0 ]; then
        print_error "This script should not be run as root"
        exit 1
    fi
}

# Проверить наличие необходимых зависимостей
check_dependencies() {
    local missing_deps=()

    if ! command -v hyprctl >/dev/null 2>&1; then
        missing_deps+=("hyprctl")
    fi

    if [ ${#missing_deps[@]} -gt 0 ]; then
        print_error "Missing required dependencies: ${missing_deps[*]}"
        print_error "Make sure hyprctl are installed"
        exit 1
    fi
}

# =============================================================================
# ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ
# =============================================================================

# Функция для подсчета подключенных мониторов
count_monitors() {
	hyprctl monitors | grep -c '^Monitor'
}

# Функция для извлечения имени монитора
monitor_name() {
	echo "$1" | cut -d',' -f1
}

# =============================================================================
# ОСНОВНАЯ ЛОГИКА
# =============================================================================

main() {
	local monitor_count=$(count_monitors)
	echo "Current monitor count: $monitor_count"

	if [ "$monitor_count" -gt 1 ]; then
		# Если подключен внешний монитор, отключаем встроенный
		hyprctl keyword monitor "$(monitor_name "$(BUILDIN_MONITOR)), disable"

		print_success "Built-in monitor disabled"
	else
		# Если только встроенный монитор, включаем его
		hyprctl keyword monitor "$(BUILDIN_MONITOR)"

		print_success "Built-in monitor enabled"
	fi
}

# =============================================================================
# ТОЧКА ВХОДА
# =============================================================================

# Проверки при запуске
check_user
check_dependencies

sleep 2

# Запуск основной логики
main "$@"
