#Requires AutoHotkey v2
#SingleInstance Force

If !A_IsAdmin {
    MsgBox('Installer must run as administrator!', 'Warning', 0x30)
    ExitApp
}

InstallRegKey := "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\AoE II AIO"
Installer := Gui('-MinimizeBox', 'Setup')
Installer.OnEvent('Close', (*) => ExitApp())
Try {
    HIcon := LoadPicture('Shell32.dll', 'Icon123')
    Installer.AddPicture(, 'HBITMAP:*' HIcon)
}
Installer.SetFont('Bold s11', 'Calibri')
Task := A_Args.Length ? A_Args[1] : 'Install'
Installer.AddText('ym+7 cGreen', 'Age of Empires II Easy Manager Installer')
InstallBtn := Installer.AddButton('xm+100 w100', Task)
InstallBtn.OnEvent('Click', Install)
InstallPrg := Installer.AddProgress('xm -Smooth w300 h17')
Installer.Show()
Install(Ctrl, Info) {
    Try {
        InstallBtn.Text := Task 'ing...'
        InstallBtn.Enabled := False
        AppDir := A_ProgramFiles '\AoE II AIO'
        If !DirExist(AppDir '\Lib') {
            DirCreate(AppDir '\Lib')
        }
        Download('https://raw.githubusercontent.com/Chandoul/aoeii_easy_manager/main/Lib/CloseGame.ahk', AppDir '\Lib\CloseGame.ahk')
        Download('https://raw.githubusercontent.com/Chandoul/aoeii_easy_manager/main/Lib/DefaultPB.ahk', AppDir '\Lib\DefaultPB.ahk')
        Download('https://raw.githubusercontent.com/Chandoul/aoeii_easy_manager/main/Lib/DMBackup.ahk', AppDir '\Lib\DMBackup.ahk')
        Download('https://raw.githubusercontent.com/Chandoul/aoeii_easy_manager/main/Lib/DownloadPackage.ahk', AppDir '\Lib\DownloadPackage.ahk')
        Download('https://raw.githubusercontent.com/Chandoul/aoeii_easy_manager/main/Lib/EnableControl.ahk', AppDir '\Lib\EnableControl.ahk')
        Download('https://raw.githubusercontent.com/Chandoul/aoeii_easy_manager/main/Lib/ExecScript.ahk', AppDir '\Lib\ExecScript.ahk')
        Download('https://raw.githubusercontent.com/Chandoul/aoeii_easy_manager/main/Lib/ExtractPackage.ahk', AppDir '\Lib\ExtractPackage.ahk')
        Download('https://raw.githubusercontent.com/Chandoul/aoeii_easy_manager/main/Lib/FolderGetSize.ahk', AppDir '\Lib\FolderGetSize.ahk')
        Download('https://raw.githubusercontent.com/Chandoul/aoeii_easy_manager/main/Lib/GetConnectedState.ahk', AppDir '\Lib\GetConnectedState.ahk')
        Download('https://raw.githubusercontent.com/Chandoul/aoeii_easy_manager/main/Lib/HashFile.ahk', AppDir '\Lib\HashFile.ahk')
        Download('https://raw.githubusercontent.com/Chandoul/aoeii_easy_manager/main/Lib/IBButtons.ahk', AppDir '\Lib\IBButtons.ahk')
        Download('https://raw.githubusercontent.com/Chandoul/aoeii_easy_manager/main/Lib/ImageButton.ahk', AppDir '\Lib\ImageButton.ahk')
        Download('https://raw.githubusercontent.com/Chandoul/aoeii_easy_manager/main/Lib/Json.ahk', AppDir '\Lib\Json.ahk')
        Download('https://raw.githubusercontent.com/Chandoul/aoeii_easy_manager/main/Lib/Prepare.ahk', AppDir '\Lib\Prepare.ahk')
        Download('https://raw.githubusercontent.com/Chandoul/aoeii_easy_manager/main/Lib/ReadWriteJSON.ahk', AppDir '\Lib\ReadWriteJSON.ahk')
        Download('https://raw.githubusercontent.com/Chandoul/aoeii_easy_manager/main/Lib/ScrollBar.ahk', AppDir '\Lib\ScrollBar.ahk')
        Download('https://raw.githubusercontent.com/Chandoul/aoeii_easy_manager/main/Lib/ValidGame.ahk', AppDir '\Lib\ValidGame.ahk')
        Download('https://raw.githubusercontent.com/Chandoul/aoeii_easy_manager/main/AHK.ahk', AppDir '\AHK.ahk')
        Download('https://raw.githubusercontent.com/Chandoul/aoeii_easy_manager/main/AoE II Manager AIO.ahk', AppDir '\AoE II Manager AIO.ahk')
        Download('https://raw.githubusercontent.com/Chandoul/aoeii_easy_manager/main/AoE II Manager.json', AppDir '\AoE II Manager.json')
        Download('https://raw.githubusercontent.com/Chandoul/aoeii_easy_manager/main/DDF.ahk', AppDir '\DDF.ahk')
        Download('https://raw.githubusercontent.com/Chandoul/aoeii_easy_manager/main/DM.ahk', AppDir '\DM.ahk')
        Download('https://raw.githubusercontent.com/Chandoul/aoeii_easy_manager/main/Fixs.ahk', AppDir '\Fixs.ahk')
        Download('https://raw.githubusercontent.com/Chandoul/aoeii_easy_manager/main/Game.ahk', AppDir '\Game.ahk')
        Download('https://raw.githubusercontent.com/Chandoul/aoeii_easy_manager/main/Installer.ahk', AppDir '\Installer.ahk')
        Download('https://raw.githubusercontent.com/Chandoul/aoeii_easy_manager/main/Language.ahk', AppDir '\Language.ahk')
        Download('https://raw.githubusercontent.com/Chandoul/aoeii_easy_manager/main/Uninstaller.ahk', AppDir '\Uninstaller.ahk')
        Download('https://raw.githubusercontent.com/Chandoul/aoeii_easy_manager/main/UninstallGame.ahk', AppDir '\UninstallGame.ahk')
        Download('https://raw.githubusercontent.com/Chandoul/aoeii_easy_manager/main/Version.ahk', AppDir '\Version.ahk')
        Download('https://raw.githubusercontent.com/Chandoul/aoeii_easy_manager/main/VM.ahk', AppDir '\VM.ahk')
        Download('https://raw.githubusercontent.com/Chandoul/aoeii_easy_manager/main/VPN.ahk', AppDir '\VPN.ahk')
        UpdateGameReg(AppDir)
        InstallPrg.Value := 100
        Sleep(1000)
        InstallBtn.Text := Task 'ed'
        If 'Yes' = MsgBox(Task ' complete!`n`nWant to launch the app now?', 'Setup', 0x40 + 0x4) {
            Run(AppDir '\AoE II Manager AIO.ahk', AppDir)
        }
        ExitApp()
    } Catch Error As Err {
        MsgBox(Task " failed!`n`n" Err.Message '`n' Err.Line '`n' Err.File, 'Version', 0x10)
    }
}
; Updates installation registery settings
UpdateGameReg(AppDir) {
    RegWrite('Age of Empires II Easy Manager', 'REG_SZ', InstallRegKey, 'DisplayName')
    RegWrite('2.0', 'REG_SZ', InstallRegKey, 'DisplayVersion')
    RegWrite(A_AhkPath, 'REG_SZ', InstallRegKey, 'DisplayIcon')
    RegWrite(AppDir, 'REG_SZ', InstallRegKey, 'InstallLocation')
    RegWrite(1, 'REG_DWORD', InstallRegKey, 'NoModify')
    RegWrite(1, 'REG_DWORD', InstallRegKey, 'NoRepair')
    RegWrite(FolderGetSize(AppDir), 'REG_DWORD', InstallRegKey, 'EstimatedSize')
    RegWrite('Smile@GR', 'REG_SZ', InstallRegKey, 'Publisher')
    RegWrite('"' A_AhkPath '" "' AppDir '\Uninstaller.ahk" "' AppDir '"', 'REG_SZ', InstallRegKey, 'UninstallString')
}
; Returns a folder size in KB
FolderGetSize(Location) {
    Size := 0
    Loop Files, Location '\*.*', 'R' {
        Size += FileGetSize(A_LoopFileFullPath, 'K')
    }
    Return Size
}