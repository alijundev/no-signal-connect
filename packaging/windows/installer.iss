#ifndef MyAppVersion
  #define MyAppVersion "0.1.0"
#endif

[Setup]
AppId={{8E4B2A91-3C4D-4F1E-9A7B-1D2E3F4A5B6C}
AppName=No Signal, Connect!
AppVersion={#MyAppVersion}
AppPublisher=No Signal Team
DefaultDirName={autopf}\No Signal Connect
DefaultGroupName=No Signal, Connect!
AllowNoIcons=yes
OutputDir=..\..\dist
OutputBaseFilename=NoSignalConnect-{#MyAppVersion}-Windows-Setup
Compression=lzma2
SolidCompression=yes
WizardStyle=modern
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "..\..\builds\windows\NoSignalConnect.exe"; DestDir: "{app}"; Flags: ignoreversion

[Icons]
Name: "{group}\No Signal, Connect!"; Filename: "{app}\NoSignalConnect.exe"
Name: "{group}\{cm:UninstallProgram,No Signal, Connect!}"; Filename: "{uninstallexe}"
Name: "{autodesktop}\No Signal, Connect!"; Filename: "{app}\NoSignalConnect.exe"; Tasks: desktopicon

[Run]
Filename: "{app}\NoSignalConnect.exe"; Description: "{cm:LaunchProgram,No Signal, Connect!}"; Flags: nowait postinstall skipifsilent