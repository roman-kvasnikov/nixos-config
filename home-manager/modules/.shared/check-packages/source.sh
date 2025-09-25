#!/usr/bin/env bash

# Строгий режим для bash
set -euo pipefail
IFS=$'\n\t'

# Массив для отсутствующих зависимостей
missing_packages=()

# Проверяем каждую зависимость
for package in "$@"; do
    if ! command -v "$package" >/dev/null 2>&1; then
        missing_packages+=("$package")
    fi
done

# Если есть отсутствующие зависимости
if [ ${#missing_packages[@]} -gt 0 ]; then
    print --error "Missing required packages: ${missing_packages[*]}"
    print --error "Make sure ${missing_packages[*]} are installed"
    exit 1
fi

print --success "All packages available: $*"