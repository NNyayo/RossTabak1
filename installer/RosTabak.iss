#define MyAppName "RosTabak"
#define MyAppVersion "1.0.1"
#define MyAppPublisher "RosTabak"
#define MyAppExeName "rosstabak_manager.exe"

[Setup]

AppId={{RosTabakManager}}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}

DefaultDirName={autopf}\RosTabak
DefaultGroupName=RosTabak

OutputDir=output
OutputBaseFilename=RosTabak-Setup

Compression=lzma
SolidCompression=yes

ArchitecturesInstallIn64BitMode=x64


[Files]

Source: "..\build\windows\x64\runner\Release\*"; \
DestDir: "{app}"; \
Flags: recursesubdirs createallsubdirs


; Visual C++ Runtime installer
Source: "vc_redist.x64.exe"; \
DestDir: "{tmp}"; \
Flags: deleteafterinstall


[Icons]

Name: "{autodesktop}\RosTabak"; \
Filename: "{app}\{#MyAppExeName}"

Name: "{group}\RosTabak"; \
Filename: "{app}\{#MyAppExeName}"


[Run]

Filename: "{tmp}\vc_redist.x64.exe"; \
Parameters: "/install /quiet /norestart"; \
StatusMsg: "Установка компонентов Microsoft Visual C++..."

Filename: "{app}\{#MyAppExeName}"; \
Description: "Запустить RosTabak"; \
Flags: nowait postinstall skipifsilent
