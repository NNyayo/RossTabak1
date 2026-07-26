export 'app/app.dart';

import 'dart:io';
import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'app/app.dart';

/// Путь к директории логов рядом с исполняемым файлом.
String get _logDirectoryPath {
  if (Platform.isWindows) {
    // На Windows exe лежит в папке, рядом создаём logs/
    final exeDir = File(Platform.resolvedExecutable).parent.path;
    return '$exeDir/logs';
  } else if (Platform.isLinux) {
    final exeDir = File(Platform.resolvedExecutable).parent.path;
    return '$exeDir/logs';
  } else if (Platform.isMacOS) {
    // На macOS — рядом с .app или в домашней директории
    final home = Platform.environment['HOME'] ?? '/tmp';
    return '$home/Library/Logs/RossTabak';
  } else {
    return 'logs';
  }
}

/// Полный путь к файлу лога ошибок.
String get _logFilePath => '$_logDirectoryPath/rosstabak_error.log';

/// Создаёт директорию для логов, если её нет.
Future<void> _ensureLogDirectory() async {
  final dir = Directory(_logDirectoryPath);
  if (!await dir.exists()) {
    await dir.create(recursive: true);
  }
}

/// Записывает сообщение в файл лога.
Future<void> _writeToLog(String message) async {
  try {
    await _ensureLogDirectory();
    final file = File(_logFilePath);
    await file.writeAsString(
      '${DateTime.now().toIso8601String()} | $message\n',
      mode: FileMode.append,
    );
  } catch (_) {
    // Если не удалось записать лог — игнорируем, чтобы не вызвать рекурсию.
  }
}

/// Форматирует ошибку и stack trace для записи в лог.
String _formatError({
  required String stage,
  required dynamic error,
  StackTrace? stackTrace,
}) {
  final buffer = StringBuffer();
  buffer.writeln('=== ERROR ===');
  buffer.writeln('Stage: $stage');
  buffer.writeln('Type: ${error.runtimeType}');
  buffer.writeln('Message: $error');
  if (stackTrace != null) {
    buffer.writeln('StackTrace:');
    buffer.writeln(stackTrace.toString());
  }
  buffer.writeln('==============');
  return buffer.toString();
}

void main() async {
  // 1. Глобальный обработчик необработанных ошибок Flutter
  FlutterError.onError = (FlutterErrorDetails details) {
    _writeToLog(
      _formatError(
        stage: 'FlutterError.onError',
        error: details.exception,
        stackTrace: details.stack,
      ),
    );
  };

  // 2. Глобальный обработчик ошибок платформы (асинхронные ошибки вне зоны Flutter)
  ui.PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    _writeToLog(
      _formatError(
        stage: 'PlatformDispatcher.onError',
        error: error,
        stackTrace: stack,
      ),
    );
    return true; // Ошибка обработана
  };

  try {
    await _writeToLog(
      _formatError(stage: 'AppStart', error: 'Application started'),
    );

    WidgetsFlutterBinding.ensureInitialized();

    await _writeToLog(
      _formatError(
        stage: 'Init',
        error: 'WidgetsFlutterBinding.ensureInitialized() completed',
      ),
    );

    if (Platform.isWindows || Platform.isLinux) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;

      await _writeToLog(
        _formatError(
          stage: 'Init',
          error: 'sqfliteFfiInit() and databaseFactory initialized',
        ),
      );
    }

    await _writeToLog(
      _formatError(stage: 'AppStart', error: 'Calling runApp()'),
    );

    runApp(const RossTabakApp());
  } catch (e, stackTrace) {
    await _writeToLog(
      _formatError(stage: 'main() catch', error: e, stackTrace: stackTrace),
    );

    // Перебрасываем, чтобы приложение всё равно упало с ошибкой
    // (но лог уже записан)
    rethrow;
  }
}
