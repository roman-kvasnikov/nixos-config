#!/usr/bin/env bash

# Строгий режим для bash
set -euo pipefail
IFS=$'\n\t'

# =============================================================================
# КОНСТАНТЫ И КОНФИГУРАЦИЯ
# =============================================================================

# Основные пути
readonly CONFIG_DIR="@configDirectory@"
readonly CONFIG_FILE="@configFile@"
readonly PASSWORD_FILE="@passwordFile@"
readonly MOUNT_POINT="@mountPoint@"

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

    if ! command -v jq >/dev/null 2>&1; then
        missing_deps+=("jq")
    fi

    if [ ${#missing_deps[@]} -gt 0 ]; then
        print_error "Missing required dependencies: ${missing_deps[*]}"
        print_error "Make sure jq is installed"
        exit 1
    fi
}

# =============================================================================
# РАБОТА С КОНФИГУРАЦИЕЙ
# =============================================================================

# Создать конфигурационный файл из примера, если его нет
ensure_config() {
    mkdir -p "$CONFIG_DIR"

    if [ ! -f "$CONFIG_FILE" ]; then
        local example_file="$CONFIG_DIR/config.example.json"

        if [ ! -f "$example_file" ]; then
            print_error "Example config file not found: $example_file"
            exit 1
        fi

        print_info "Creating default config from example..."
        cp "$example_file" "$CONFIG_FILE"
        print_success "Config created at: $CONFIG_FILE"
    fi
}

# Получить настройки из config.json (поддерживает вложенные пути)
get_config_value() {
    local field="$1"  # "bucket", "url", "usePathRequestStyle", "dbglevel"

    ensure_config

    # Используем jq для получения значения по пути (поддерживает точечную нотацию)
    jq -r ".$field // empty" "$CONFIG_FILE" 2>/dev/null
}

# Создать NetworkManager L2TP соединение
mount() {
    local bucket url usePathRequestStyle dbglevel

    bucket=$(get_config_value "bucket")
    url=$(get_config_value "url")
    usePathRequestStyle=$(get_config_value "usePathRequestStyle")
    dbglevel=$(get_config_value "dbglevel")

    print_info "Mounting S3 bucket: $bucket ..."

    # Удалить существующее подключение если есть
    if mount | grep -q "$MOUNT_POINT"; then
        print_warning "S3 bucket already mounted at $MOUNT_POINT"
        return
    fi

    # Создать директорию для монтирования, если она не существует
    mkdir -p "$MOUNT_POINT"

    # Монтировать S3 bucket
    s3fs "$bucket" "$MOUNT_POINT" \
        -o passwd_file="$PASSWORD_FILE" \
        -o url="$url" \
        -o use_path_request_style="$usePathRequestStyle" \
        -o dbglevel="$dbglevel" \
        -f

    print_success "S3 bucket mounted successfully"
}

unmount() {
    print_info "Unmounting S3 bucket: $MOUNT_POINT ..."
    umount "$MOUNT_POINT"
    print_success "S3 bucket unmounted successfully"
}

# =============================================================================
# ОСНОВНАЯ ЛОГИКА
# =============================================================================

# Обработка команд
main() {
    local command="${1:-}"

    case "$command" in
        mount)
            mount
        ;;
        unmount)
            unmount
        ;;
        *)
            show_help
            exit 1
            ;;
    esac
}

# Показать справку
show_help() {
    print_header "🏠 S3FS Management Tool"
    echo ""
    print_info "Usage: s3fsctl {command}"
    echo ""

    print_status "🚀 Quick commands:"
    echo -e "  ${GREEN}mount${NC}                Mount S3 bucket"
    echo -e "  ${RED}unmount${NC}             Unmount S3 bucket"
    echo ""

    print_status "💡 Example usage:"
    echo -e "  s3fsctl mount     # Mount S3 bucket"
    echo -e "  s3fsctl unmount  # Unmount S3 bucket"
    echo ""

    print_info "Configuration file: $CONFIG_FILE"
    print_info "Required format:"
    print_info "  {"
    print_info "    \"bucket\": \"bucket-name\","
    print_info "    \"url\": \"https://s3.example.com\","
    print_info "    \"usePathRequestStyle\": false,"
    print_info "    \"dbglevel\": \"debug\""
    print_info "  }"
}

# =============================================================================
# ТОЧКА ВХОДА
# =============================================================================

# Проверки при запуске
check_user
check_dependencies

# Запуск основной логики
main "$@"