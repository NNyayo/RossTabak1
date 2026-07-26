#!/bin/bash

set -e

PROJECT_ROOT="/Users/vladislavlesuk/Desktop/Rosstabak TEST/relese/Code"
BUILD_DIR="$PROJECT_ROOT/build/macos/Build/Products/Release"
RELEASE_DIR="/Users/vladislavlesuk/Desktop/Rosstabak TEST/relese/release/MacOS"

echo "=========================================="
echo "🚀 Начинаем сборку релиза Rosstabak"
echo "=========================================="
echo ""

cd "$PROJECT_ROOT"

echo "🧹 Очищаем проект..."
flutter clean
echo "✅ Очистка завершена"
echo ""

echo "📦 Устанавливаем зависимости..."
flutter pub get
echo "✅ Зависимости установлены"
echo ""

echo "🔨 Собираем release-версию для macOS..."
flutter build macos --release
echo "✅ Сборка завершена"
echo ""

if [ ! -d "$BUILD_DIR/Rosstabak.app" ]; then
  echo "❌ Ошибка: собранное приложение не найдено в $BUILD_DIR"
  exit 1
fi

echo "🗑️  Удаляем старую версию из релизной папки..."
rm -rf "$RELEASE_DIR/Rosstabak.app"
echo "✅ Старая версия удалена"
echo ""

echo "📋 Копируем новую версию..."
cp -R "$BUILD_DIR/Rosstabak.app" "$RELEASE_DIR/"
echo "✅ Новая версия скопирована"
echo ""

echo "=========================================="
echo "🎉 Готово!"
echo "📁 Путь к приложению:"
echo "   $RELEASE_DIR/Rosstabak.app"
echo "=========================================="
