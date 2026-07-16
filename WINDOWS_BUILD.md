# Сборка для Windows

## Требования
- Windows 10+
- Flutter SDK 3.12.2+
- Dart SDK 3.12.2+
- Visual Studio 2019+ с "Desktop development with C++"
- CMake (установится автоматически с Flutter)

## Установка зависимостей для Windows

Для работы SQLite на Windows нужен FFI-бэкенд. Добавьте в `pubspec.yaml`:

```yaml
dependencies:
  sqflite: ^2.4.3
  sqflite_common_ffi: ^2.3.2  # <-- добавить для Windows/Linux
```

Затем:
```bash
flutter pub get
```

## Инициализация FFI в main.dart

В файл `lib/main.dart` добавьте в начало `main()`:

```dart
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Инициализация FFI для Windows/Linux
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  } else if (Platform.operatingSystem == 'windows' ||
             Platform.operatingSystem == 'linux') {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(const RossTabakApp());
}
```

## Сборка

```bash
# Debug
flutter run -d windows

# Release
flutter build windows --release
```

Готовый `.exe` будет в:
```
build/windows/x64/runner/Release/rosstabak_manager.exe
```

## Известные проблемы
- Первый запуск может быть медленным — FFI загружает SQLite
- Размер приложения ~50-80 МБ (включая FFI-бэкенд)
