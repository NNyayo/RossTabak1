# RossTabak Manager

Профессиональная CRM-система для управления сетью торговых точек «РоссТабак».

## О проекте

RossTabak Manager — desktop-first приложение на Flutter для macOS. Проект построен на SQLite, Material 3 и чистой архитектуре с разделением слоев.

## Зачем это нужно

- Управление торговыми точками
- Управление сотрудниками и их рабочими точками
- Создание и назначение задач
- Ведение смен и отчетов
- Удобная работа администраторов

## Как запустить

```bash
flutter pub get
flutter run -d macos
```

## Структура проекта

- `lib/core` — глобальные константы, цвета, утилиты
- `lib/database` — схема базы и доступ к SQLite
- `lib/models` — модели предметной области
- `lib/repositories` — слой доступа к данным
- `lib/services` — бизнес-логика и сервисы
- `lib/widgets` — повторно используемые компоненты
- `lib/screens` — экраны приложения
- `docs` — проектная документация

## Документы

- `docs/00_PROJECT_OVERVIEW.md`
- `docs/01_ARCHITECTURE.md`
- `docs/02_DATABASE.md`
- `docs/03_UI_UX.md`
- `docs/04_BUSINESS_LOGIC.md`
- `docs/05_DEVELOPMENT_ROADMAP.md`
- `docs/06_AI_DEVELOPER_RULES.md`
- `docs/07_FUTURE_FEATURES.md`
- `docs/08_STYLE_GUIDE.md`
