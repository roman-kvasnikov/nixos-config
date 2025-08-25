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
readonly LOG_FILE="$CONFIG_DIR/s3fsctl.log"

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
# ЛОГИРОВАНИЕ
# =============================================================================

# Логировать событие (с проверкой прав записи)
log_event() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    # Проверяем возможность записи в лог файл
    if [ -w "$(dirname "$LOG_FILE")" ] 2>/dev/null || mkdir -p "$(dirname "$LOG_FILE")" 2>/dev/null; then
        echo "[$timestamp] [$level] $message" >> "$LOG_FILE" 2>/dev/null || true
    fi
}

# =============================================================================
# ВАЛИДАЦИЯ И ПРОВЕРКИ
# =============================================================================

# Проверить, что скрипт запущен не от root
check_user() {
    if [ "$(id -u)" -eq 0 ]; then
        print_error "This script should not be run as root"
        log_event "ERROR" "Script run as root - security violation"
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

    if ! command -v grep >/dev/null 2>&1; then
        missing_deps+=("grep")
    fi

    if ! command -v mount >/dev/null 2>&1; then
        missing_deps+=("mount")
    fi

    if ! command -v umount >/dev/null 2>&1; then
        missing_deps+=("umount")
    fi

    if [ ${#missing_deps[@]} -gt 0 ]; then
        print_error "Missing required dependencies: ${missing_deps[*]}"
        print_error "Make sure s3fs, jq, grep, mount, umount are installed"
        log_event "ERROR" "Missing dependencies: ${missing_deps[*]}"
        exit 1
    fi
}

# Проверить валидность JSON конфигурации
validate_json_config() {
    if [ ! -f "$CONFIG_FILE" ]; then
        return 1
    fi

    # Проверка синтаксиса JSON
    if ! jq empty "$CONFIG_FILE" >/dev/null 2>&1; then
        print_error "Invalid JSON syntax in config file: $CONFIG_FILE"
        log_event "ERROR" "Invalid JSON syntax in config file"
        return 1
    fi

    # Проверка структуры - должен быть объект с бакетами
    if ! jq -e 'type == "object"' "$CONFIG_FILE" >/dev/null 2>&1; then
        print_error "Config file must contain a JSON object"
        log_event "ERROR" "Config file is not a JSON object"
        return 1
    fi

    return 0
}

# Валидировать путь на предмет безопасности
validate_path() {
    local path="$1"
    local path_type="$2"  # "mount" or "password"

    # Проверка на directory traversal
    if [[ "$path" == *".."* ]]; then
        print_error "Path contains '..' which is not allowed: $path"
        log_event "ERROR" "Security: Path traversal attempt in $path_type: $path"
        return 1
    fi

    # Проверка на абсолютный путь
    if [[ "$path" != /* ]]; then
        print_error "Only absolute paths are allowed: $path"
        log_event "ERROR" "Security: Relative path not allowed in $path_type: $path"
        return 1
    fi

    # Проверка на системные директории для mount points
    if [ "$path_type" = "mount" ]; then
        local system_dirs=("/bin" "/sbin" "/usr" "/etc" "/boot" "/dev" "/proc" "/sys")
        for sys_dir in "${system_dirs[@]}"; do
            if [[ "$path" == "$sys_dir"* ]]; then
                print_error "Mounting in system directory is not allowed: $path"
                log_event "ERROR" "Security: Attempt to mount in system directory: $path"
                return 1
            fi
        done
    fi

    return 0
}

# Проверить доступность S3 endpoint
check_s3_endpoint() {
    local url="$1"
    local bucket_name="$2"

    # Проверяем доступность через curl с таймаутом
    if command -v curl >/dev/null 2>&1; then
        if ! curl -s --connect-timeout 10 --max-time 30 "$url" >/dev/null 2>&1; then
            print_warning "S3 endpoint may not be accessible: $url (for bucket: $bucket_name)"
            log_event "WARNING" "S3 endpoint check failed for $bucket_name: $url"
            return 1
        fi
    fi

    return 0
}

# =============================================================================
# РАБОТА С КОНФИГУРАЦИЕЙ
# =============================================================================

# Создать конфигурационный файл из примера, если его нет
ensure_config() {
    mkdir -p "$CONFIG_DIR"

    # Пытаемся создать лог файл (опционально)
    if [ ! -f "$LOG_FILE" ] && [ -w "$(dirname "$LOG_FILE")" ] 2>/dev/null; then
        touch "$LOG_FILE" 2>/dev/null && chmod 640 "$LOG_FILE" 2>/dev/null || true
    fi

    if [ ! -f "$CONFIG_FILE" ]; then
        local example_file="$CONFIG_DIR/config.example.json"

        if [ ! -f "$example_file" ]; then
            print_error "Example config file not found: $example_file"
            log_event "ERROR" "Example config file not found: $example_file"
            exit 1
        fi

        print_info "Creating default config from example..."
        cp "$example_file" "$CONFIG_FILE"
        chmod 640 "$CONFIG_FILE"
        print_success "Config created at: $CONFIG_FILE"
        log_event "INFO" "Default config created from example"
    fi

    # Валидируем конфигурацию
    if ! validate_json_config; then
        exit 1
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
    local value
    value=$(jq -r ".$bucket_name.$field // empty" "$CONFIG_FILE" 2>/dev/null)
    
    # Валидируем пути
    if [ "$field" = "mountPoint" ] && [ -n "$value" ]; then
        if ! validate_path "$value" "mount"; then
            return 1
        fi
    elif [ "$field" = "passwordFile" ] && [ -n "$value" ]; then
        if ! validate_path "$value" "password"; then
            return 1
        fi
    fi
    
    echo "$value"
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
        log_event "ERROR" "Password file not found for $bucket_name: $password_file"
        return 1
    fi

    # Проверяем права доступа к файлу паролей
    local file_perms
    file_perms=$(stat -c "%a" "$password_file" 2>/dev/null || echo "unknown")
    if [ "$file_perms" != "600" ] && [ "$file_perms" != "400" ]; then
        print_warning "Password file has insecure permissions: $file_perms (should be 600 or 400)"
        chmod 600 "$password_file"
        log_event "WARNING" "Fixed password file permissions for $bucket_name: $password_file"
    fi

    # Проверяем доступность S3 endpoint
    check_s3_endpoint "$url" "$bucket_name" || true  # Не блокируем, только предупреждаем

    print_info "Mounting S3 bucket: $bucket_name ($bucket) to $mount_point ..."
    log_event "INFO" "Starting mount operation for $bucket_name: $bucket -> $mount_point"

    # Проверяем, не смонтирован ли уже бакет
    if mount | grep -q "$mount_point"; then
        print_warning "S3 bucket $bucket_name already mounted at $mount_point"
        log_event "WARNING" "Bucket $bucket_name already mounted at $mount_point"
        return 0
    fi

    # Создаем директорию для монтирования, если она не существует
    if ! mkdir -p "$mount_point" 2>/dev/null; then
        print_error "Cannot create mount point directory: $mount_point"
        log_event "ERROR" "Failed to create mount point for $bucket_name: $mount_point"
        return 1
    fi

    # Проверяем права на запись в родительскую директорию
    local parent_dir
    parent_dir=$(dirname "$mount_point")
    if [ ! -w "$parent_dir" ]; then
        print_error "No write permission for mount point parent directory: $parent_dir"
        log_event "ERROR" "No write permission for $bucket_name mount point parent: $parent_dir"
        return 1
    fi

    # Монтируем S3 bucket с безопасными опциями
    local mount_options="passwd_file=$password_file,url=$url,use_path_request_style,allow_other,uid=$(id -u),gid=$(id -g),umask=077"
    
    if s3fs "$bucket" "$mount_point" -o "$mount_options" >/dev/null 2>&1; then
        print_success "S3 bucket $bucket_name mounted successfully to $mount_point"
        log_event "INFO" "Successfully mounted $bucket_name: $bucket -> $mount_point"
        
        # Проверяем, что монтирование действительно работает
        if ! timeout 10 ls "$mount_point" >/dev/null 2>&1; then
            print_warning "Mount succeeded but directory is not accessible (may take time to initialize)"
            log_event "WARNING" "Mount point not immediately accessible for $bucket_name"
        fi
    else
        print_error "Failed to mount S3 bucket $bucket_name"
        log_event "ERROR" "Failed to mount $bucket_name: $bucket -> $mount_point"
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
    if ! mount | grep -q "$mount_point"; then
        print_warning "S3 bucket $bucket_name is not mounted at $mount_point"
        return 0
    fi

    print_info "Unmounting S3 bucket: $bucket_name ($mount_point) ..."
    log_event "INFO" "Starting unmount operation for $bucket_name: $mount_point"
    
    # Попытка graceful unmount
    if umount "$mount_point" 2>/dev/null; then
        print_success "S3 bucket $bucket_name unmounted successfully"
        log_event "INFO" "Successfully unmounted $bucket_name: $mount_point"
    elif umount -l "$mount_point" 2>/dev/null; then  # lazy unmount
        print_success "S3 bucket $bucket_name unmounted successfully (lazy unmount)"
        log_event "INFO" "Successfully unmounted $bucket_name with lazy unmount: $mount_point"
    else
        print_error "Failed to unmount S3 bucket $bucket_name"
        log_event "ERROR" "Failed to unmount $bucket_name: $mount_point"
        return 1
    fi
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

# Получить список команд для completion
list_buckets() {
    local buckets
    buckets=$(get_all_buckets 2>/dev/null || true)
    
    if [ -n "$buckets" ]; then
        echo "$buckets"
    fi
}

# Показать логи
show_logs() {
    local lines="${1:-50}"
    
    if [ ! -f "$LOG_FILE" ]; then
        print_info "No log file found at: $LOG_FILE"
        return 0
    fi
    
    print_header "S3FSCtl Logs (last $lines lines):"
    echo ""
    tail -n "$lines" "$LOG_FILE" 2>/dev/null || {
        print_error "Failed to read log file: $LOG_FILE"
        return 1
    }
}

# Очистить логи
clear_logs() {
    if [ -f "$LOG_FILE" ]; then
        > "$LOG_FILE"
        print_success "Log file cleared: $LOG_FILE"
        log_event "INFO" "Log file cleared by user"
    else
        print_info "No log file to clear"
    fi
}

# Обработка команд
main() {
    local command="${1:-}"
    local bucket_name="${2:-}"

    case "$command" in
        mount)
            if [ -n "$bucket_name" ]; then
                # Монтировать конкретный бакет
                if mount_bucket "$bucket_name"; then
                    print_success "Bucket $bucket_name mounted successfully"
                else
                    print_error "Failed to mount bucket $bucket_name"
                    exit 1
                fi
            else
                # Монтировать все бакеты
                mount
            fi
        ;;
        unmount)
            if [ -n "$bucket_name" ]; then
                # Размонтировать конкретный бакет
                if unmount_bucket "$bucket_name"; then
                    print_success "Bucket $bucket_name unmounted successfully"
                else
                    print_error "Failed to unmount bucket $bucket_name"
                    exit 1
                fi
            else
                # Размонтировать все бакеты
                unmount
            fi
        ;;
        status)
            if [ -n "$bucket_name" ]; then
                # Статус конкретного бакета
                local mount_point
                mount_point=$(get_bucket_config "$bucket_name" "mountPoint")
                
                if [ -z "$mount_point" ]; then
                    print_error "Bucket not found in configuration: $bucket_name"
                    exit 1
                fi
                
                print_header "Status for bucket: $bucket_name"
                if mount | grep -q "$mount_point"; then
                    print_success "✓ $bucket_name: MOUNTED at $mount_point"
                else
                    print_info "○ $bucket_name: NOT MOUNTED"
                fi
            else
                # Статус всех бакетов
                show_status
            fi
        ;;
        list)
            print_header "Available buckets in configuration:"
            local buckets
            buckets=$(get_all_buckets)
            if [ -z "$buckets" ]; then
                print_info "No buckets configured"
            else
                while IFS= read -r bucket; do
                    if [ -n "$bucket" ]; then
                        print_info "  - $bucket"
                    fi
                done <<< "$buckets"
            fi
        ;;
        logs)
            show_logs "${bucket_name:-50}"
        ;;
        clear-logs)
            clear_logs
        ;;
        config)
            print_header "🔧 S3FSCtl Configuration:"
            print_info "Config file: $CONFIG_FILE"
            print_info "Config directory: $CONFIG_DIR"
            print_info "Log file: $LOG_FILE"
            
            if [ -f "$CONFIG_FILE" ]; then
                echo ""
                print_info "Configured buckets:"
                list_buckets | while IFS= read -r bucket; do
                    if [ -n "$bucket" ]; then
                        local mount_point url
                        mount_point=$(get_bucket_config "$bucket" "mountPoint")
                        url=$(get_bucket_config "$bucket" "url")
                        print_status "  $bucket: $url -> $mount_point"
                    fi
                done
            else
                print_warning "Config file not found. Run 's3fsctl mount' to create from example."
            fi
        ;;
        test)
            if [ -n "$bucket_name" ]; then
                print_header "Testing configuration for bucket: $bucket_name"
                
                local bucket url password_file mount_point
                bucket=$(get_bucket_config "$bucket_name" "bucket")
                url=$(get_bucket_config "$bucket_name" "url")
                password_file=$(get_bucket_config "$bucket_name" "passwordFile")
                mount_point=$(get_bucket_config "$bucket_name" "mountPoint")
                
                # Проверка конфигурации
                local errors=0
                
                if [ -z "$bucket" ]; then
                    print_error "Missing 'bucket' field"
                    errors=$((errors + 1))
                else
                    print_success "Bucket name: $bucket"
                fi
                
                if [ -z "$url" ]; then
                    print_error "Missing 'url' field"
                    errors=$((errors + 1))
                else
                    print_success "S3 URL: $url"
                    check_s3_endpoint "$url" "$bucket_name"
                fi
                
                if [ -z "$password_file" ]; then
                    print_error "Missing 'passwordFile' field"
                    errors=$((errors + 1))
                elif [ ! -f "$password_file" ]; then
                    print_error "Password file not found: $password_file"
                    errors=$((errors + 1))
                else
                    print_success "Password file: $password_file"
                    local perms
                    perms=$(stat -c "%a" "$password_file" 2>/dev/null || echo "unknown")
                    if [ "$perms" = "600" ] || [ "$perms" = "400" ]; then
                        print_success "Password file permissions: $perms (secure)"
                    else
                        print_warning "Password file permissions: $perms (should be 600 or 400)"
                    fi
                fi
                
                if [ -z "$mount_point" ]; then
                    print_error "Missing 'mountPoint' field"
                    errors=$((errors + 1))
                else
                    print_success "Mount point: $mount_point"
                    if [ -d "$mount_point" ]; then
                        print_success "Mount point directory exists"
                    else
                        print_info "Mount point directory will be created"
                    fi
                fi
                
                echo ""
                if [ $errors -eq 0 ]; then
                    print_success "Configuration test passed for $bucket_name"
                else
                    print_error "Configuration test failed with $errors errors"
                    exit 1
                fi
            else
                print_error "Please specify bucket name: s3fsctl test <bucket-name>"
                exit 1
            fi
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
    print_info "Usage: s3fsctl {command} [bucket-name]"
    echo ""

    print_status "🚀 Main commands:"
    echo -e "  ${GREEN}mount [bucket]${NC}       Mount all buckets or specific bucket"
    echo -e "  ${RED}unmount [bucket]${NC}     Unmount all buckets or specific bucket"
    echo -e "  ${BLUE}status [bucket]${NC}      Show status of all buckets or specific bucket"
    echo ""

    print_status "🔧 Management commands:"
    echo -e "  ${CYAN}list${NC}                 List all configured buckets"
    echo -e "  ${CYAN}config${NC}               Show current configuration"
    echo -e "  ${CYAN}test <bucket>${NC}        Test configuration for specific bucket"
    echo ""

    print_status "📜 Logging commands:"
    echo -e "  ${YELLOW}logs [lines]${NC}         Show recent log entries (default: 50)"
    echo -e "  ${YELLOW}clear-logs${NC}           Clear log file"
    echo ""

    print_status "💡 Example usage:"
    echo -e "  s3fsctl mount              # Mount all configured buckets"
    echo -e "  s3fsctl mount mybucket     # Mount specific bucket"
    echo -e "  s3fsctl status             # Show status of all buckets"
    echo -e "  s3fsctl test mybucket      # Test bucket configuration"
    echo -e "  s3fsctl logs 100           # Show last 100 log entries"
    echo ""

    print_status "📁 Files and directories:"
    print_info "Config file: $CONFIG_FILE"
    print_info "Config directory: $CONFIG_DIR"
    print_info "Log file: $LOG_FILE"
    print_info "Example config: $CONFIG_DIR/config.example.json"
    echo ""
    
    print_status "📝 Configuration format:"
    print_info "  {"
    print_info "    \"MyBucket\": {"
    print_info "      \"bucket\": \"actual-bucket-name\","
    print_info "      \"url\": \"https://s3.example.com\","
    print_info "      \"passwordFile\": \"/absolute/path/to/.passwd-s3fs\","
    print_info "      \"mountPoint\": \"/absolute/path/to/mount/point\""
    print_info "    }"
    print_info "  }"
    echo ""
    
    print_status "⚠️ Security notes:"
    print_info "- Use only absolute paths"
    print_info "- Password files should have 600 or 400 permissions"
    print_info "- Each bucket must have unique mount points"
    print_info "- Avoid mounting in system directories (/bin, /usr, /etc, etc.)"
}

# =============================================================================
# ТОЧКА ВХОДА
# =============================================================================

# Проверки при запуске
check_user
check_dependencies

# Запуск основной логики
main "$@"