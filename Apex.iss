
#define MyAppName "Apex"
#define MyAppVersion "0.3.2"
#define MyAppExeName "Apex.exe"
#define BuildDir "C:\Users\ostr7\AndroidStudioProjects\Apex\cross-platform_flutter_F1\build\windows\x64\runner\Release"

[Setup]
AppId={{A7C48E2B-51D2-4A8B-9F31-7C5D2E8A1046}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
DefaultDirName={autopf}\Apex
DefaultGroupName=Apex
OutputDir=installer
OutputBaseFilename=ApexSetup-{#MyAppVersion}
Compression=lzma2
SolidCompression=yes
WizardStyle=modern
ArchitecturesInstallIn64BitMode=x64compatible
PrivilegesRequired=admin
UninstallDisplayIcon={app}\{#MyAppExeName}

[Files]
Source: "{#BuildDir}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{autoprograms}\Apex"; Filename: "{app}\{#MyAppExeName}"
Name: "{autodesktop}\Apex"; Filename: "{app}\{#MyAppExeName}"

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "Запустить Apex"; Flags: postinstall nowait skipifsilent
