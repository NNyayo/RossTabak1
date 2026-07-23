#define MyAppName "RosTabak"
#define MyAppVersion "1.0.0"
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


[Icons]

Name: "{autodesktop}\RosTabak"; \
Filename: "{app}\{#MyAppExeName}"

Name: "{group}\RosTabak"; \
Filename: "{app}\{#MyAppExeName}"


[Run]

Filename: "{app}\{#MyAppExeName}"; \
Description: "Запустить RosTabak"; \
Flags: nowait postinstall skipifsilent