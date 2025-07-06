#define APP_NAME "Age of Empires II Easy Manager"
#define APP_VERSION "3.8"
#define INSTALL_DIR "{commonpf}\Age of Empires II Easy Manager"
#define AHK "AutoHotkey"
#define SETUP_ICON "Bin\Icon.bmp"
#define SETUP_IMG "Bin\Finish.bmp"
[Setup]
AppName={#APP_NAME} v{#APP_VERSION}
AppVersion={#APP_VERSION}
AppVerName={#APP_NAME}
DefaultDirName={#INSTALL_DIR}
WizardSmallImageFile={#SETUP_ICON}
WizardImageFile={#SETUP_IMG}
OutputDir=Bin
OutputBaseFilename=AoE II Manager AIO
[Files]
Source: "Bin\AutoHotkey_2.0.18_setup.exe"; DestDir: "{app}\Bin"; Flags: ignoreversion recursesubdirs
Source: "Lib\*"; DestDir: "{app}\Lib"; Flags: ignoreversion recursesubdirs
Source: "Shortcuts\*"; DestDir: "{app}\Shortcuts"; Flags: ignoreversion recursesubdirs
Source: "DB\*"; DestDir: "{app}\DB"; Flags: ignoreversion recursesubdirs; Excludes: "Ignore,013.7z.001,015.7z.001,016.7z.001,016.7z.002,016.7z.003,016.7z.004,016.7z.005"
Source: "*.ahk"; DestDir: "{app}";
Source: "AoE II Manager.json"; DestDir: "{app}";
[Icons]
Name: "{commondesktop}\Age of Empires II Easy Manager"; Filename: "{app}\AoE II Manager AIO.ahk"; WorkingDir: "{app}"
Name: "{group}\Age of Empires II Easy Manager"; Filename: "{app}\AoE II Manager AIO.ahk"; WorkingDir: "{app}"
Name: "{group}\Uninstall Age of Empires II Easy Manager"; Filename: "{uninstallexe}"
[Run]
Filename: "{app}\AoE II Manager AIO.ahk"; Description: "Run AoE II Easy Manager v{#APP_VERSION}"; Flags: postinstall shellexec skipifsilent
[code]
// Gets the correct registery location to check if AutoHotkey is installed or not.
function GetHKLM: Integer;
begin
  if IsWin64 then
    Result := HKLM64
  else
    Result := HKLM32;
end;
function GetHKCU: Integer;
begin
  if IsWin64 then
    Result := HKCU64
  else
    Result := HKCU32;
end;
//------------------------

// Checks if AutoHotkey is installed or not.
function AHKInstalled: boolean;
begin
  Result := True;
  if not (RegKeyExists(GetHKLM, 'SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\AutoHotkey') 
       or RegKeyExists(GetHKCU, 'SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\AutoHotkey')) then
    Result := False
end;
//-----------------------------------------------------------------------------------------------------

// Checks if AutoHotkey is installed before starting the installation.
function InitializeSetup: Boolean;
begin
  Result := True;
  if not AHKInstalled then
  begin
    Result := False;
    if MsgBox('Please install {#AHK} first!', mbError, MB_OKCANCEL) = IDOK then
      Result := True;
  end;
end;
//-----------------------------------------------------------------------------

// Checks if AutoHotkey is installed after completing the installation.
procedure CurStepChanged(CurStep: TSetupStep);
var
  ErrorCode: Integer;
begin
  if CurStep = ssPostInstall then
  begin
    if not AHKInstalled then
    begin
      If MsgBox('Install {#AHK} now?!', mbConfirmation, MB_YesNo) = IDYes then
        ShellExec('', ExpandConstant('{app}\Bin\AutoHotkey_2.0.18_setup.exe'), '', '', SW_SHOWNORMAL, ewWaitUntilTerminated, ErrorCode);
    end;
  end;
end;
//--------------------------------------------------------------------------------------------------------------------------------------

procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
begin
  // warn the user, that his working folder is going to be deleted and projects might get lost
  if (CurUninstallStep = usUninstall) then begin
  
    if MsgBox('***WARNING***'#13#10#13#10 +
        'The installation folder is [ '+ ExpandConstant('{app}') +' ].'#13#10 +
        'You are about to delete this folder and all its subfolders,'#13#10 +
        'including [ '+ ExpandConstant('{app}') +'\important_projects_folder ], which may contain your projects.'#13#10#13#10 +
        'This is your last chance to do a backup of your files.'#13#10#13#10 +
        'Do you want to proceed?'#13#10, mbConfirmation, MB_YESNO) = IDYES
    then begin
      // User clicked: YES
      DelTree(ExpandConstant('{app}'), True, True, True);

    end else begin
      // User clicked: No
      Abort;
    end;
  end;
end;