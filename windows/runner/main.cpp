#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>
#include <windows.h>

#include <chrono>
#include <fstream>
#include <iostream>
#include <string>
#include <filesystem>
#include <dbghelp.h>
#include <signal.h>
#include <iomanip>

#include "flutter_window.h"
#include "utils.h"

namespace fs = std::filesystem;

#pragma comment(lib, "dbghelp.lib")

// -------------------------------------------------------------------
// Helper functions (defined BEFORE they are used)
// -------------------------------------------------------------------

/// Returns the directory where the executable is located.
static fs::path GetExeDir() {
  wchar_t path[MAX_PATH];
  GetModuleFileNameW(nullptr, path, MAX_PATH);
  return fs::path(path).parent_path();
}

/// Writes a message to logs/startup.log next to the executable.
static void WriteStartupLog(const std::wstring& message) {
  try {
    fs::path exeDir = GetExeDir();
    fs::path logDir = exeDir / L"logs";
    fs::create_directories(logDir);

    fs::path logFile = logDir / L"startup.log";
    std::ofstream log(logFile, std::ios::app);
    if (log.is_open()) {
      auto now = std::chrono::system_clock::now();
      auto now_time_t = std::chrono::system_clock::to_time_t(now);
      struct tm timeinfo;
      localtime_s(&timeinfo, &now_time_t);

      char timestamp[64];
      strftime(timestamp, sizeof(timestamp), "%Y-%m-%d %H:%M:%S", &timeinfo);

      log << timestamp << " | ";
      // Convert wstring to string for output
      int len = WideCharToMultiByte(CP_UTF8, 0, message.c_str(), -1, nullptr, 0, nullptr, nullptr);
      if (len > 0) {
        std::string msg(len - 1, 0);
        WideCharToMultiByte(CP_UTF8, 0, message.c_str(), -1, &msg[0], len, nullptr, nullptr);
        log << msg;
      }
      log << std::endl;
      log.close();
    }
  } catch (...) {
    // Ignore logging errors — we must not crash before Flutter starts
  }
}

/// Checks if a file exists.
static bool FileExists(const fs::path& path) {
  return fs::exists(path);
}

/// Checks if a DLL can be loaded (returns true if yes).
static bool CanLoadDll(const fs::path& dllPath) {
  HMODULE hModule = LoadLibraryW(dllPath.c_str());
  if (hModule) {
    FreeLibrary(hModule);
    return true;
  }
  return false;
}

// -------------------------------------------------------------------
// Global exception handler for uncatchable crashes
// -------------------------------------------------------------------

/// Writes a crash dump to logs/crash.dmp next to the executable.
static void WriteMiniDump(EXCEPTION_POINTERS* exceptionPointers) {
  try {
    fs::path exeDir = GetExeDir();
    fs::path logDir = exeDir / L"logs";
    fs::create_directories(logDir);

    fs::path dumpFile = logDir / L"crash.dmp";
    HANDLE hFile = CreateFileW(
      dumpFile.c_str(), GENERIC_WRITE, 0, nullptr, CREATE_ALWAYS,
      FILE_ATTRIBUTE_NORMAL, nullptr
    );
    if (hFile != INVALID_HANDLE_VALUE) {
      MINIDUMP_EXCEPTION_INFORMATION mei;
      mei.ThreadId = GetCurrentThreadId();
      mei.ExceptionPointers = exceptionPointers;
      mei.ClientPointers = FALSE;

      MiniDumpWriteDump(
        GetCurrentProcess(), GetCurrentProcessId(), hFile,
        MiniDumpWithDataSegs, &mei, nullptr, nullptr
      );
      CloseHandle(hFile);
    }
  } catch (...) {
    // Ignore
  }
}

/// Global unhandled exception filter (catches crashes like access violation).
static LONG WINAPI GlobalExceptionHandler(EXCEPTION_POINTERS* exceptionInfo) {
  DWORD code = exceptionInfo->ExceptionRecord->ExceptionCode;

  WriteStartupLog(L"=== UNHANDLED EXCEPTION ===");
  WriteStartupLog(L"ExceptionCode: 0x" + std::to_wstring(code));

  switch (code) {
    case EXCEPTION_ACCESS_VIOLATION:
      WriteStartupLog(L"EXCEPTION_ACCESS_VIOLATION (segfault)");
      break;
    case EXCEPTION_ILLEGAL_INSTRUCTION:
      WriteStartupLog(L"EXCEPTION_ILLEGAL_INSTRUCTION");
      break;
    case EXCEPTION_STACK_OVERFLOW:
      WriteStartupLog(L"EXCEPTION_STACK_OVERFLOW");
      break;
    case EXCEPTION_BREAKPOINT:
      WriteStartupLog(L"EXCEPTION_BREAKPOINT");
      break;
    case EXCEPTION_DATATYPE_MISALIGNMENT:
      WriteStartupLog(L"EXCEPTION_DATATYPE_MISALIGNMENT");
      break;
    case EXCEPTION_SINGLE_STEP:
      WriteStartupLog(L"EXCEPTION_SINGLE_STEP");
      break;
    case EXCEPTION_PRIV_INSTRUCTION:
      WriteStartupLog(L"EXCEPTION_PRIV_INSTRUCTION");
      break;
    case EXCEPTION_IN_PAGE_ERROR:
      WriteStartupLog(L"EXCEPTION_IN_PAGE_ERROR");
      break;
    case EXCEPTION_NONCONTINUABLE_EXCEPTION:
      WriteStartupLog(L"EXCEPTION_NONCONTINUABLE_EXCEPTION");
      break;
    case EXCEPTION_ARRAY_BOUNDS_EXCEEDED:
      WriteStartupLog(L"EXCEPTION_ARRAY_BOUNDS_EXCEEDED");
      break;
    case EXCEPTION_FLT_DIVIDE_BY_ZERO:
      WriteStartupLog(L"EXCEPTION_FLT_DIVIDE_BY_ZERO");
      break;
    case EXCEPTION_INT_DIVIDE_BY_ZERO:
      WriteStartupLog(L"EXCEPTION_INT_DIVIDE_BY_ZERO");
      break;
    case EXCEPTION_FLT_OVERFLOW:
      WriteStartupLog(L"EXCEPTION_FLT_OVERFLOW");
      break;
    case EXCEPTION_INT_OVERFLOW:
      WriteStartupLog(L"EXCEPTION_INT_OVERFLOW");
      break;
    default:
      WriteStartupLog(L"Unknown exception code");
      break;
  }

  if (code == EXCEPTION_ACCESS_VIOLATION) {
    ULONG_PTR accessType = exceptionInfo->ExceptionRecord->ExceptionInformation[0];
    ULONG_PTR address = exceptionInfo->ExceptionRecord->ExceptionInformation[1];
    WriteStartupLog(L"Access type: " + std::wstring(accessType == 0 ? L"READ" : L"WRITE"));
    WriteStartupLog(L"Fault address: 0x" + std::to_wstring(address));
    if (address == 0) {
      WriteStartupLog(L"-> NULL pointer dereference — likely missing DLL dependency");
    }
  }

  WriteMiniDump(exceptionInfo);

  WriteStartupLog(L"=== END UNHANDLED EXCEPTION ===");

  return EXCEPTION_EXECUTE_HANDLER;
}

// -------------------------------------------------------------------
// Entry point
// -------------------------------------------------------------------

int APIENTRY wWinMain(_In_ HINSTANCE instance, _In_opt_ HINSTANCE prev,
                      _In_ wchar_t *command_line, _In_ int show_command) {
  // Install global unhandled exception filter FIRST
  SetUnhandledExceptionFilter(GlobalExceptionHandler);

  WriteStartupLog(L"=== RosTabak Manager START ===");

  // Log command line
  WriteStartupLog(L"Command line: " + std::wstring(command_line));

  // Get executable directory
  fs::path exeDir = GetExeDir();
  WriteStartupLog(L"Executable directory: " + exeDir.wstring());

  // Check for flutter_windows.dll
  fs::path flutterDllPath = exeDir / L"flutter_windows.dll";
  bool flutterDllExists = FileExists(flutterDllPath);
  WriteStartupLog(L"flutter_windows.dll exists: " + std::wstring(flutterDllExists ? L"YES" : L"NO"));

  // Check for data directory
  fs::path dataDirPath = exeDir / L"data";
  bool dataDirExists = FileExists(dataDirPath);
  WriteStartupLog(L"data directory exists: " + std::wstring(dataDirExists ? L"YES" : L"NO"));

  // Check for flutter_assets inside data
  fs::path assetsDirPath = exeDir / L"data" / L"flutter_assets";
  bool assetsDirExists = FileExists(assetsDirPath);
  WriteStartupLog(L"data/flutter_assets exists: " + std::wstring(assetsDirExists ? L"YES" : L"NO"));

  // Try to load flutter_windows.dll to check dependencies
  if (flutterDllExists) {
    WriteStartupLog(L"Attempting to load flutter_windows.dll...");
    if (CanLoadDll(flutterDllPath)) {
      WriteStartupLog(L"flutter_windows.dll loaded successfully");
    } else {
      DWORD err = GetLastError();
      WriteStartupLog(L"flutter_windows.dll FAILED to load. GetLastError=" + std::to_wstring(err));
      if (err == 126) {
        WriteStartupLog(L"-> ERROR_MOD_NOT_FOUND: flutter_windows.dll is missing a dependency");
        WriteStartupLog(L"-> Likely missing: VCRUNTIME140.dll, MSVCP140.dll, or VCRUNTIME140_1.dll");
      }
    }
  }

  // Check for common MSVC runtime DLLs
  wchar_t sysDirBuf[MAX_PATH];
  UINT sysDirLen = GetSystemDirectoryW(sysDirBuf, MAX_PATH);
  fs::path sysDir = fs::path(std::wstring(sysDirBuf, sysDirLen));

  WriteStartupLog(L"System directory: " + sysDir.wstring());

  bool vcruntimeExists = FileExists(sysDir / L"VCRUNTIME140.dll");
  WriteStartupLog(L"VCRUNTIME140.dll in system32: " + std::wstring(vcruntimeExists ? L"YES" : L"NO"));

  bool msvcpExists = FileExists(sysDir / L"MSVCP140.dll");
  WriteStartupLog(L"MSVCP140.dll in system32: " + std::wstring(msvcpExists ? L"YES" : L"NO"));

  bool vcruntime1401Exists = FileExists(sysDir / L"VCRUNTIME140_1.dll");
  WriteStartupLog(L"VCRUNTIME140_1.dll in system32: " + std::wstring(vcruntime1401Exists ? L"YES" : L"NO"));

  // Also check app directory for these DLLs
  bool vcruntimeLocal = FileExists(exeDir / L"VCRUNTIME140.dll");
  WriteStartupLog(L"VCRUNTIME140.dll in app dir: " + std::wstring(vcruntimeLocal ? L"YES" : L"NO"));

  bool msvcpLocal = FileExists(exeDir / L"MSVCP140.dll");
  WriteStartupLog(L"MSVCP140.dll in app dir: " + std::wstring(msvcpLocal ? L"YES" : L"NO"));

  // Attach to console when present (e.g., 'flutter run') or create a
  // new console when running with a debugger.
  if (!::AttachConsole(ATTACH_PARENT_PROCESS) && ::IsDebuggerPresent()) {
    CreateAndAttachConsole();
  }

  // Initialize COM, so that it is available for use in the library and/or
  // plugins.
  HRESULT comResult = ::CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);
  WriteStartupLog(L"CoInitializeEx result: 0x" + std::to_wstring(comResult));

  flutter::DartProject project(L"data");

  std::vector<std::string> command_line_arguments =
      GetCommandLineArguments();

  project.set_dart_entrypoint_arguments(std::move(command_line_arguments));

  WriteStartupLog(L"Creating FlutterWindow...");

  FlutterWindow window(project);
  Win32Window::Point origin(10, 10);
  Win32Window::Size size(1280, 720);
  if (!window.Create(L"rosstabak_manager", origin, size)) {
    DWORD err = GetLastError();
    WriteStartupLog(L"ERROR: FlutterWindow::Create() FAILED. GetLastError=" + std::to_wstring(err));
    return EXIT_FAILURE;
  }
  WriteStartupLog(L"FlutterWindow created successfully");
  window.SetQuitOnClose(true);

  ::MSG msg;
  while (::GetMessage(&msg, nullptr, 0, 0)) {
    ::TranslateMessage(&msg);
    ::DispatchMessage(&msg);
  }

  WriteStartupLog(L"=== RosTabak Manager END ===");

  ::CoUninitialize();
  return EXIT_SUCCESS;
}