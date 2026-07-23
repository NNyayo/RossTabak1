# Rosstabak Manager

Профессиональная CRM-система для управления сетью торговых точек «РоссТабак».

## О проекте

Desktop-first приложение на Flutter для macOS и Windows. Построено на SQLite, Material 3 и чистой архитектуре с разделением слоев.

## Как скачать готовую программу

### Для Windows (проще некуда)

1. Открой [GitHub → Releases](https://github.com/ТВОЙ_НИК/rosstabak-manager/releases) этого проекта
2. Найди последнюю версию (сверху)
3. В разделе **Assets** нажми **Rosstabak-Windows-Portable.zip** — скачается архив
4. Распакуй архив → открой папку → запусти `rosstabak_manager.exe`

**Готово.** Программа работает сразу, без установок и дополнительного софта.

### Для macOS
1. Перейди на страницу проекта в GitHub
2. Вкладка **Releases** (справа)
3. Скачай последний `Rosstabak.dmg`
4. Открой файл → программа запустится

---

## Как собрать самому

Подробная инструкция: [`build/BUILD_INSTRUCTIONS.md`](build/BUILD_INSTRUCTIONS.md)

Коротко:
```bash
flutter pub get
flutter run -d macos   # или -d windows
```

Готовые сборки собираются через GitHub Actions:
1. Запушь код в GitHub
2. GitHub → Actions → **Build Release** → Run workflow
3. Скачай артефакты через ~15 минут

---

## Структура проекта

```
rosstabak_manager/
├── lib/                    # Исходный код
│   ├── main.dart           # Точка входа
│   ├── app/                # Настройки приложения (тема, роуты)
│   ├── constants/          # Константы (роли, статусы, смены)
│   ├── controllers/        # Логика управления данными
│   ├── core/               # Цвета, хеширование, утилиты
│   ├── database/           # SQLite схема и миграции
│   ├── models/             # Модели данных
│   ├── providers/          # Провайдеры состояния (Riverpod/Provider)
│   ├── repositories/       # Доступ к данным
│   ├── screens/            # Экраны (admin, auth, employee)
│   ├── services/           # Бизнес-логика и сервисы
│   ├── utils/              # Вспомогательные функции
│   └── widgets/            # Повторно используемые компоненты
├── build/                  # Инструкции по сборке и установщик
│   ├── BUILD_INSTRUCTIONS.md
│   └── windows/installer/  # Конфигурация Inno Setup для Windows
├── docs/                   # Проектная документация
├── test/                   # Тесты
├── android/                # Платформа Android
├── ios/                    # Платформа iOS
├── linux/                  # Платформа Linux
├── macos/                  # Платформа macOS
├── windows/                # Платформа Windows (исходники Flutter)
├── web/                    # Веб-платформа
├── assets/                 # Ресурсы (иконки, изображения)
└── release/                # Готовые .dmg и файлы релиза
```

## Зачем это нужно

- Управление торговыми точками
- Управление сотрудниками и их рабочими точками
- Создание и назначение задач
- Ведение смен и отчетов
- Удобная работа администраторов

## Документация

- [`docs/00_PROJECT_OVERVIEW.md`](docs/00_PROJECT_OVERVIEW.md)
- [`docs/01_ARCHITECTURE.md`](docs/01_ARCHITECTURE.md)
- [`docs/02_DATABASE.md`](docs/02_DATABASE.md)
- [`docs/03_UI_UX.md`](docs/03_UI_UX.md)
- [`docs/04_BUSINESS_LOGIC.md`](docs/04_BUSINESS_LOGIC.md)
- [`docs/05_DEVELOPMENT_ROADMAP.md`](docs/05_DEVELOPMENT_ROADMAP.md)
- [`docs/06_AI_DEVELOPER_RULES.md`](docs/06_AI_DEVELOPER_RULES.md)
- [`docs/07_FUTURE_FEATURES.md`](docs/07_FUTURE_FEATURES.md)
- [`docs/08_STYLE_GUIDE.md`](docs/08_STYLE_GUIDE.md)

## Технологии

- **Flutter** — кроссплатформенный фреймворк
- **SQLite** — локальная база данных
- **Material 3** — дизайн-система
- **GitHub Actions** — CI/CD и сборка релизов
- **.dmg** — установщик для macOS
- **Inno Setup** — (опционально) установщик для Windows
