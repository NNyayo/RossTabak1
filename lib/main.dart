export 'app/app.dart';

import 'dart:io';
import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'app/app.dart';

// =====================================================================
// Diagnostic logging system
// =====================================================================

/// Returns the path to the logs directory.
/// Uses %LOCALAPPDATA% on Windows (always writable),
/// ~/Library/Logs on macOS, or a local 'logs' folder otherwise.
String get _logDirectoryPath {
  if (Platform.isWindows) {
    final appData =
        Platform.environment['LOCALAPPDATA'] ??
        Platform.environment['APPDATA'] ??
        '${Platform.environment['USERPROFILE']}\\AppData\\Local';
    return '$appData\\RossTabak\\logs';
  } else if (Platform.isLinux) {
    final home = Platform.environment['HOME'] ?? '/tmp';
    return '$home/.local/share/RossTabak/logs';
  } else if (Platform.isMacOS) {
    final home = Platform.environment['HOME'] ?? '/tmp';
    return '$home/Library/Logs/RossTabak';
  } else {
    return 'logs';
  }
}

/// Full path to the error log file.
String get _logFilePath => '$_logDirectoryPath/rosstabak_error.log';

/// Ensures the logs directory exists.
Future<void> _ensureLogDirectory() async {
  final dir = Directory(_logDirectoryPath);
  if (!await dir.exists()) {
    await dir.create(recursive: true);
  }
}

/// Writes a message to the log file with a timestamp.
Future<void> _writeToLog(String message) async {
  try {
    await _ensureLogDirectory();
    final file = File(_logFilePath);
    await file.writeAsString(
      '${DateTime.now().toIso8601String()} | $message\n',
      mode: FileMode.append,
    );
  } catch (_) {
    // Silently ignore log write failures to avoid recursion.
  }
}

/// Formats an error with stage, type, message, and optional stack trace.
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

// =====================================================================
// Main entry point
// =====================================================================

void main() async {
  // 1. Global Flutter error handler
  FlutterError.onError = (FlutterErrorDetails details) {
    _writeToLog(
      _formatError(
        stage: 'FlutterError.onError',
        error: details.exception,
        stackTrace: details.stack,
      ),
    );
  };

  // 2. Global platform error handler (async errors outside Flutter zone)
  ui.PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    _writeToLog(
      _formatError(
        stage: 'PlatformDispatcher.onError',
        error: error,
        stackTrace: stack,
      ),
    );
    return true; // Error was handled
  };

  try {
    // --- Stage 1: App start ---
    await _writeToLog(
      _formatError(stage: 'AppStart', error: 'Application started'),
    );

    // --- Stage 2: Flutter binding ---
    WidgetsFlutterBinding.ensureInitialized();

    await _writeToLog(
      _formatError(
        stage: 'Init',
        error: 'WidgetsFlutterBinding.ensureInitialized() completed',
      ),
    );

    // --- Stage 3: SQLite FFI initialization (Windows/Linux only) ---
    if (Platform.isWindows || Platform.isLinux) {
      try {
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi;

        await _writeToLog(
          _formatError(
            stage: 'Init',
            error:
                'sqfliteFfiInit() and databaseFactory initialized successfully',
          ),
        );
      } catch (e, stackTrace) {
        await _writeToLog(
          _formatError(
            stage: 'Init.sqfliteFfiInit',
            error: e,
            stackTrace: stackTrace,
          ),
        );
        // Don't rethrow — let the app try to start anyway
        // (it will fail later with a clear error in the log)
      }
    }

    // --- Stage 4: Run app ---
    await _writeToLog(
      _formatError(stage: 'AppStart', error: 'Calling runApp()'),
    );

    runApp(const RossTabakApp());

    await _writeToLog(
      _formatError(stage: 'AppStart', error: 'runApp() completed successfully'),
    );
  } catch (e, stackTrace) {
    await _writeToLog(
      _formatError(stage: 'main() catch', error: e, stackTrace: stackTrace),
    );

    // Keep the app alive for 2 seconds so the log write completes
    await Future.delayed(const Duration(seconds: 2));

    // Rethrow so the OS knows the app crashed
    rethrow;
  }
}
