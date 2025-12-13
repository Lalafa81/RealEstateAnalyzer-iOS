#!/bin/bash

# Скрипт для автоматического обновления версии и сборки из Git
# Использование: добавьте этот скрипт как "Run Script" в Build Phases

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_DIR"

# Получаем версию из Git тега (если есть) или используем дефолтную
GIT_VERSION=$(git describe --tags --abbrev=0 2>/dev/null | sed 's/^v//')
if [ -z "$GIT_VERSION" ]; then
    # Если тегов нет, используем формат 0.X.0 где X - количество коммитов / 10
    COMMIT_COUNT=$(git rev-list --count HEAD 2>/dev/null || echo "0")
    MAJOR=0
    MINOR=$((COMMIT_COUNT / 10))
    PATCH=0
    GIT_VERSION="${MAJOR}.${MINOR}.${PATCH}"
fi

# Получаем количество коммитов для сборки
BUILD_NUMBER=$(git rev-list --count HEAD 2>/dev/null || echo "1")

# Обновляем MARKETING_VERSION и CURRENT_PROJECT_VERSION в project.pbxproj
PROJECT_FILE="${PROJECT_DIR}/RealEstateAnalyzer.xcodeproj/project.pbxproj"

if [ -f "$PROJECT_FILE" ]; then
    # Обновляем MARKETING_VERSION
    sed -i '' "s/MARKETING_VERSION = [^;]*/MARKETING_VERSION = ${GIT_VERSION}/g" "$PROJECT_FILE"
    
    # Обновляем CURRENT_PROJECT_VERSION
    sed -i '' "s/CURRENT_PROJECT_VERSION = [^;]*/CURRENT_PROJECT_VERSION = ${BUILD_NUMBER}/g" "$PROJECT_FILE"
    
    echo "✅ Версия обновлена: ${GIT_VERSION} (Build: ${BUILD_NUMBER})"
else
    echo "❌ Файл проекта не найден: $PROJECT_FILE"
    exit 1
fi
