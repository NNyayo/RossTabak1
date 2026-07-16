# Architecture

## Технический стек

- Flutter
- Dart
- SQLite (sqflite)
- Material 3
- macOS (desktop-first)

## Архитектурные слои

- Presentation
  - screens
  - widgets
- Business logic
  - services
  - providers
- Data access
  - repositories
  - database
- Models
  - models
- Core
  - core

## Почему так

- `screens` отвечает за визуальные экраны.
- `widgets` содержит повторно используемые компоненты.
- `services` и `providers` инкапсулируют логику и состояние.
- `repositories` скрывают доступ к SQLite.
- `database` содержит создание схемы и работу с базой.
- `models` описывают сущности предметной области.
- `core` содержит глобальные константы, цвета и утилиты.

## Взаимодействие

1. UI запрашивает данные через `providers` или `services`.
2. Провайдер вызывает `repository`.
3. `Repository` работает с `database`.
4. `database` возвращает `Map<String, dynamic>`, конвертированный в `models`.
5. UI отображает данные через `widgets`.
