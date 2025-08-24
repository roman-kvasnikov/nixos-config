#!/usr/bin/env bash

# Строгий режим для bash
set -euo pipefail
IFS=$'\n\t'

trap 'cleanup' EXIT INT TERM

# =============================================================================
# КОНСТАНТЫ И КОНФИГУРАЦИЯ
# =============================================================================

# Основные пути
readonly CONFIG_DIR="@configDirectory@"
readonly CONFIG_FILE="@configFile@"

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

    if ! command -v s3fs >/dev/null 2>&1; then
        missing_deps+=("s3fs")
    fi

    if ! command -v jq >/dev/null 2>&1; then
        missing_deps+=("jq")
    fi

    if [ ${#missing_deps[@]} -gt 0 ]; then
        print_error "Missing required dependencies: ${missing_deps[*]}"
        print_error "Make sure s3fs and jq are installed"
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

# Получить список всех бакетов из конфигурации
get_all_buckets() {
    ensure_config

    # Получаем все ключи верхнего уровня (имена бакетов)
    jq -r 'keys[]' "$CONFIG_FILE" 2>/dev/null
}

# Получить настройки конкретного бакета
get_bucket_config() {
    local bucket_name="$1"
    local field="$2"

    ensure_config

    # Получаем значение поля для конкретного бакета
    jq -r ".$bucket_name.$field // empty" "$CONFIG_FILE" 2>/dev/null
}

# =============================================================================
# МОНТИРОВАНИЕ И ДЕМОНТИРОВАНИЕ
# =============================================================================

# Монтировать конкретный бакет
mount_bucket() {
    local bucket_name="$1"

    local bucket=$(get_bucket_config "$bucket_name" "bucket")
    local url=$(get_bucket_config "$bucket_name" "url")
    local password_file=$(get_bucket_config "$bucket_name" "passwordFile")
    local mount_point=$(get_bucket_config "$bucket_name" "mountPoint")

    # Проверяем обязательные поля
    if [ -z "$bucket" ] || [ -z "$url" ] || [ -z "$password_file" ] || [ -z "$mount_point" ]; then
        print_error "Missing required configuration for bucket: $bucket_name"
        return 1
    fi

    # Проверяем, существует ли файл с паролем
    if [ ! -f "$password_file" ]; then
        print_error "Password file not found: $password_file"
        return 1
    fi

    chmod 600 "$password_file"

    print_info "Mounting S3 bucket: $bucket_name ($bucket) to $mount_point ..."

    # Проверяем, не смонтирован ли уже бакет
    if mount | grep -q "$mount_point"; then
        print_warning "S3 bucket $bucket_name already mounted at $mount_point"
        return 0
    fi

    # Создаем директорию для монтирования, если она не существует
    mkdir -p "$mount_point"

    # Проверяем, можно ли писать в директорию для монтирования
    # if [ ! -w "$(dirname "$mount_point")" ]; then
    #     print_error "Cannot write to mount point directory: $mount_point"
    #     return 1
    # fi

    # Монтируем S3 bucket
    if s3fs "$bucket" "$mount_point" \
        -o passwd_file="$password_file" \
        -o url="$url" \
        -o use_path_request_style \
        -o dbglevel="info" \
        -f; then
        print_success "S3 bucket $bucket_name mounted successfully to $mount_point"
    else
        print_error "Failed to mount S3 bucket $bucket_name"
        return 1
    fi
}

# Монтировать все бакеты
mount() {
    local buckets
    local failed_mounts=()

    print_info "Starting to mount all S3 buckets..."

    # Получаем список всех бакетов
    buckets=$(get_all_buckets)

    if [ -z "$buckets" ]; then
        print_error "No buckets found in configuration"
        return 1
    fi

    # Монтируем каждый бакет по очереди
    while IFS= read -r bucket_name; do
        if [ -n "$bucket_name" ]; then
            if ! mount_bucket "$bucket_name"; then
                failed_mounts+=("$bucket_name")
            fi
        fi
    done <<< "$buckets"

    # Выводим итоговый результат
    if [ ${#failed_mounts[@]} -eq 0 ]; then
        print_success "All S3 buckets mounted successfully!"
    else
        print_warning "Some buckets failed to mount: ${failed_mounts[*]}"
        return 1
    fi
}

# Демонтировать конкретный бакет
unmount_bucket() {
    local bucket_name="$1"
    local mount_point=$(get_bucket_config "$bucket_name" "mountPoint")

    # Проверяем, существует ли директория для монтирования
    if [ -z "$mount_point" ]; then
        print_error "Mount point not configured for bucket: $bucket_name"
        return 1
    fi

    # Проверяем, смонтирован ли бакет
    # if ! mount | grep -q "$mount_point"; then
    #     print_warning "S3 bucket $bucket_name is not mounted at $mount_point"
    #     return 0
    # fi

    print_info "Unmounting S3 bucket: $bucket_name ($mount_point) ..."
    umount "$mount_point"
    print_success "S3 bucket $bucket_name unmounted successfully"
}

# Демонтировать все бакеты
unmount() {
    local buckets
    local failed_unmounts=()

    print_info "Starting to unmount all S3 buckets..."

    # Получаем список всех бакетов
    buckets=$(get_all_buckets)

    if [ -z "$buckets" ]; then
        print_error "No buckets found in configuration"
        return 1
    fi

    # Демонтируем каждый бакет по очереди
    while IFS= read -r bucket_name; do
        if [ -n "$bucket_name" ]; then
            if ! unmount_bucket "$bucket_name" 2>/dev/null; then
                failed_unmounts+=("$bucket_name")
            fi
        fi
    done <<< "$buckets"

    # Выводим итоговый результат
    if [ ${#failed_unmounts[@]} -eq 0 ]; then
        print_success "All S3 buckets unmounted successfully!"
    else
        print_warning "Some buckets failed to unmount: ${failed_unmounts[*]}"
        return 1
    fi
}

# Показать статус всех бакетов
show_status() {
    local buckets
    local total_buckets=0
    local mounted_buckets=0

    print_header "S3FS Status Report"
    echo ""

    buckets=$(get_all_buckets)

    while IFS= read -r bucket_name; do
        if [ -n "$bucket_name" ]; then
            total_buckets=$((total_buckets + 1))
            local mount_point
            mount_point=$(get_bucket_config "$bucket_name" "mountPoint")

            if [ -n "$mount_point" ] && mount | grep -q "$mount_point"; then
                print_success "✓ $bucket_name: MOUNTED at $mount_point"
                mounted_buckets=$((mounted_buckets + 1))
            else
                print_info "○ $bucket_name: NOT MOUNTED"
            fi
        fi
    done <<< "$buckets"

    if [ -z "$buckets" ]; then
        print_warning "No buckets found in configuration"
        return 0
    fi

    echo ""
    print_status "Summary: $mounted_buckets/$total_buckets buckets mounted"
}

cleanup() {
    print_info "Cleaning up..."

    # Проверяем, есть ли активные монтирования
    local active_mounts=$(mount | grep -c "s3fs" || true)
    if [ "$active_mounts" -gt 0 ]; then
        print_warning "Found $active_mounts active S3 mounts. Consider unmounting manually."
    fi
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
        status)
            show_status
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
    print_info "Example config location: $CONFIG_DIR/config.example.json"
    print_info "Required format:"
    print_info "  {"
    print_info "    \"Bucket-1\": {"
    print_info "      \"bucket\": \"bucket-1\","
    print_info "      \"url\": \"https://s3.example.com\","
    print_info "      \"passwordFile\": \"path/to/.passwd-s3fs\","
    print_info "      \"mountPoint\": \"path/to/mount/point\""
    print_info "    },"
    print_info "    \"Bucket-2\": {"
    print_info "      \"bucket\": \"bucket-2\","
    print_info "      \"url\": \"https://s3.example.com\","
    print_info "      \"passwordFile\": \"path/to/.passwd-s3fs\","
    print_info "      \"mountPoint\": \"path/to/mount/point\""
    print_info "    }"
    print_info "  }"
    print_info ""
    print_info "Note: Each bucket must have unique mount points"
    print_info "Password files should have restricted permissions (600)"
}

# =============================================================================
# ТОЧКА ВХОДА
# =============================================================================

# Проверки при запуске
check_user
check_dependencies

# Запуск основной логики
main "$@"