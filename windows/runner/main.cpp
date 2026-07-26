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
static std::wstring GetExeDir() {
  wchar_t path[MAX_PATH];
  GetModuleFileNameW(nullptr, path, MAX_PATH);
  std::wstring fullPath(path);
  auto pos = fullPath.find_last_of(L"\\");
  return (pos != std::wstring::npos) ? fullPath.substr(0, pos) : L".";
}

/// Writes a message to logs/startup.log next to the executable.
static void WriteStartupLog(const std::string& message) {
  try {
    std::wstring exeDir = GetExeDir();
    std::wstring logDir = exeDir + L"\\logs";
    fs::create_directories(logDir);

    std::wstring logFile = logDir + L"\\startup.log";
    std::ofstream log(logFile, std::ios::app);
    if (log.is_open()) {
      auto now = std::chrono::system_clock::now();
      auto now_time_t = std::chrono::system_clock::to_time_t(now);
      struct tm timeinfo;
      localtime_s(&timeinfo, &now_time_t);

      char timestamp[64];
      strftime(timestamp, sizeof(timestamp), "%Y-%m-%d %H:%M:%S", &timeinfo);

      log << timestamp << " | " << message << std::endl;
      log.close();
    }
  } catch (...) {
    // Ignore logging errors — we must not crash before Flutter starts
  }
}

/// Checks if a file exists.
static bool FileExists(const std::wstring& path) {
  return fs::exists(path);
}

/// Checks if a DLL can be loaded (returns true if yes).
static bool CanLoadDll(const std::wstring& dllName) {
  HMODULE hModule = LoadLibraryW(dllName.c_str());
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
    std::wstring exeDir = GetExeDir();
    std::wstring logDir = exeDir + L"\\logs";
    fs::create_directories(logDir);

    std::wstring dumpFile = logDir + L"\\crash.dmp";
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

  WriteStartupLog("=== UNHANDLED EXCEPTION ===");
  WriteStartupLog("ExceptionCode: 0x" + std::to_string(code));

  switch (code) {
    case EXCEPTION_ACCESS_VIOLATION:
      WriteStartupLog("EXCEPTION_ACCESS_VIOLATION (segfault)");
      break;
    case EXCEPTION_ILLEGAL_INSTRUCTION:
      WriteStartupLog("EXCEPTION_ILLEGAL_INSTRUCTION");
      break;
    case EXCEPTION_STACK_OVERFLOW:
      WriteStartupLog("EXCEPTION_STACK_OVERFLOW");
      break;
    case EXCEPTION_BREAKPOINT:
      WriteStartupLog("EXCEPTION_BREAKPOINT");
      break;
    case EXCEPTION_DATATYPE_MISALIGNMENT:
      WriteStartupLog("EXCEPTION_DATATYPE_MISALIGNMENT");
      break;
    case EXCEPTION_SINGLE_STEP:
      WriteStartupLog("EXCEPTION_SINGLE_STEP");
      break;
    case EXCEPTION_PRIV_INSTRUCTION:
      WriteStartupLog("EXCEPTION_PRIV_INSTRUCTION");
      break;
    case EXCEPTION_IN_PAGE_ERROR:
      WriteStartupLog("EXCEPTION_IN_PAGE_ERROR");
      break;
    case EXCEPTION_NONCONTINUABLE_EXCEPTION:
      WriteStartupLog("EXCEPTION_NONCONTINUABLE_EXCEPTION");
      break;
    case EXCEPTION_ARRAY_BOUNDS_EXCEEDED:
      WriteStartupLog("EXCEPTION_ARRAY_BOUNDS_EXCEEDED");
      break;
    case EXCEPTION_FLT_DIVIDE_BY_ZERO:
      WriteStartupLog("EXCEPTION_FLT_DIVIDE_BY_ZERO");
      break;
    case EXCEPTION_INT_DIVIDE_BY_ZERO:
      WriteStartupLog("EXCEPTION_INT_DIVIDE_BY_ZERO");
      break;
    case EXCEPTION_FLT_OVERFLOW:
      WriteStartupLog("EXCEPTION_FLT_OVERFLOW");
      break;
    case EXCEPTION_INT_OVERFLOW:
      WriteStartupLog("EXCEPTION_INT_OVERFLOW");
      break;
    default:
      WriteStartupLog("Unknown exception code");
      break;
  }

  if (code == EXCEPTION_ACCESS_VIOLATION) {
    ULONG_PTR accessType = exceptionInfo->ExceptionRecord->ExceptionInformation[0];
    ULONG_PTR address = exceptionInfo->ExceptionRecord->ExceptionInformation[1];
    WriteStartupLog("Access type: " + std::string(accessType == 0 ? "READ" : "WRITE"));
    WriteStartupLog("Fault address: 0x" + std::to_string(address));
    if (address == 0) {
      WriteStartupLog("-> NULL pointer dereference — likely missing DLL dependency");
    }
  }

  WriteMiniDump(exceptionInfo);

  WriteStartupLog("=== END UNHANDLED EXCEPTION ===");

  return EXCEPTION_EXECUTE_HANDLER;
}

// -------------------------------------------------------------------
// Entry point
// -------------------------------------------------------------------

int APIENTRY wWinMain(_In_ HINSTANCE instance, _In_opt_ HINSTANCE prev,
                      _In_ wchar_t *command_line, _In_ int show_command) {
  // Install global unhandled exception filter FIRST
  SetUnhandledExceptionFilter(GlobalExceptionHandler);

  WriteStartupLog("=== RosTabak Manager START ===");

  // Convert wchar_t* command line to narrow string
  std::wstring cmdWide(command_line);
  std::string cmdNarrow(cmdWide.begin(), cmdWide.end());
  WriteStartupLog("Command line: " + cmdNarrow);

  // Get executable directory
  std::wstring exeDir = GetExeDir();
  std::string exeDirA(exeDir.begin(), exeDir.end());
  WriteStartupLog("Executable directory: " + exeDirA);

  // Check for flutter_windows.dll
  std::wstring flutterDllPath = exeDir + L"\\flutter_windows.dll";
  bool flutterDllExists = FileExists(flutterDllPath);
  WriteStartupLog("flutter_windows.dll exists: " + std::string(flutterDllExists ? "YES" : "NO"));

  // Check for data directory
  std::wstring dataDirPath = exeDir + L"\\data";
  bool dataDirExists = FileExists(dataDirPath);
  WriteStartupLog("data directory exists: " + std::string(dataDirExists ? "YES" : "NO"));

  // Check for flutter_assets inside data
  std::wstring assetsDirPath = exeDir + L"\\data\\flutter_assets";
  bool assetsDirExists = FileExists(assetsDirPath);
  WriteStartupLog("data/flutter_assets exists: " + std::string(assetsDirExists ? "YES" : "NO"));

  // Try to load flutter_windows.dll to check dependencies
  if (flutterDllExists) {
    WriteStartupLog("Attempting to load flutter_windows.dll...");
    if (CanLoadDll(flutterDllPath)) {
      WriteStartupLog("flutter_windows.dll loaded successfully");
    } else {
      DWORD err = GetLastError();
      WriteStartupLog("flutter_windows.dll FAILED to load. GetLastError=" + std::to_string(err));
      if (err == 126) {
        WriteStartupLog("-> ERROR_MOD_NOT_FOUND: flutter_windows.dll is missing a dependency");
        WriteStartupLog("-> Likely missing: VCRUNTIME140.dll, MSVCP140.dll, or VCRUNTIME140_1.dll");
      }
    }
  }

  // Check for common MSVC runtime DLLs
  std::wstring sysDirW(MAX_PATH, L'\0');
  UINT sysDirLen = GetSystemDirectoryW(&sysDirW[0], MAX_PATH);
  sysDirW.resize(sysDirLen);

  WriteStartupLog("System directory: " + std::string(sysDirW.begin(), sysDirW.end()));

  bool vcruntimeExists = FileExists(sysDirW + L"\\VCRUNTIME140.dll");
  WriteStartupLog("VCRUNTIME140.dll in system32: " + std::string(vcruntimeExists ? "YES" : "NO"));

  bool msvcpExists = FileExists(sysDirW + L"\\MSVCP140.dll");
  WriteStartupLog("MSVCP140.dll in system32: " + std::string(msvcpExists ? "YES" : "NO"));

  bool vcruntime1401Exists = FileExists(sysDirW + L"\\VCRUNTIME140_1.dll");
  WriteStartupLog("VCRUNTIME140_1.dll in system32: " + std::string(vcruntime1401Exists ? "YES" : "NO"));

  // Also check app directory for these DLLs
  bool vcruntimeLocal = FileExists(exeDir + L"\\VCRUNTIME140.dll");
  WriteStartupLog("VCRUNTIME140.dll in app dir: " + std::string(vcruntimeLocal ? "YES" : "NO"));

  bool msvcpLocal = FileExists(exeDir + L"\\MSVCP140.dll");
  WriteStartupLog("MSVCP140.dll in app dir: " + std::string(msvcpLocal ? "YES" : "NO"));

  // Attach to console when present (e.g., 'flutter run') or create a
  // new console when running with a debugger.
  if (!::AttachConsole(ATTACH_PARENT_PROCESS) && ::IsDebuggerPresent()) {
    CreateAndAttachConsole();
  }

  // Initialize COM, so that it is available for use in the library and/or
  // plugins.
  HRESULT comResult = ::CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);
  WriteStartupLog("CoInitializeEx result: 0x" + std::to_string(comResult));

  flutter::DartProject project(L"data");

  std::vector<std::string> command_line_arguments =
      GetCommandLineArguments();

  project.set_dart_entrypoint_arguments(std::move(command_line_arguments));

  WriteStartupLog("Creating FlutterWindow...");

  FlutterWindow window(project);
  Win32Window::Point origin(10, 10);
  Win32Window::Size size(1280, 720);
  if (!window.Create(L"rosstabak_manager", origin, size)) {
    DWORD err = GetLastError();
    WriteStartupLog("ERROR: FlutterWindow::Create() FAILED. GetLastError=" + std::to_string(err));
    return EXIT_FAILURE;
  }
  WriteStartupLog("FlutterWindow created successfully");
  window.SetQuitOnClose(true);

  ::MSG msg;
  while (::GetMessage(&msg, nullptr, 0, 0)) {
    ::TranslateMessage(&msg);
    ::DispatchMessage(&msg);
  }

  WriteStartupLog("=== RosTabak Manager END ===");

  ::CoUninitialize();
  return EXIT_SUCCESS;
}