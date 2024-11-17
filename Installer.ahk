#Requires AutoHotkey v2
#SingleInstance Force
; Checks if the script run as admin
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
Installer.AddText('ym+7 cGreen', 'Age of Empires II Easy Manager Installer')
InstallBtn := Installer.AddButton('xm+100 w100', 'Install')
InstallBtn.OnEvent('Click', Install)
InstallPrg := Installer.AddProgress('xm -Smooth w300 h17')
Installer.Show()
Install(Ctrl, Info) {
    Try {
        InstallBtn.Text := 'Installing...'
        InstallBtn.Enabled := False
        AppDir := A_ProgramFiles '\AoE II AIO'
        If !DirExist(AppDir) {
            DirCreate(AppDir)
        }
        InstallPrg.Value := 10
        Download('https://raw.githubusercontent.com/SmileAoE/aoeii_aio/main/AoE II Manager AIO Ex.ahk', AppDir '\AoE II Manager AIO Ex.ahk')
        FileCreateShortcut(AppDir '\AoE II Manager AIO Ex.ahk', A_Desktop '\AoE II Manager AIO.lnk', AppDir)
        InstallPrg.Value := 50
        Download('https://raw.githubusercontent.com/SmileAoE/aoeii_aio/main/SharedLib.ahk', AppDir '\SharedLib.ahk')
        InstallPrg.Value := 80
        Download('https://raw.githubusercontent.com/SmileAoE/aoeii_aio/main/Uninstaller.ahk', AppDir '\Uninstaller.ahk')
        InstallPrg.Value := 90
        UpdateGameReg(AppDir)
        InstallPrg.Value := 100
        Sleep(1000)
        InstallBtn.Text := 'Installed'
        If 'Yes' = MsgBox('Installation complete!`n`nWant to launch the app now?', 'Setup', 0x40 + 0x4) {
            Run(AppDir '\AoE II Manager AIO Ex.ahk', AppDir)
        }
        ExitApp()
    } Catch Error As Err {
        MsgBox("Installation failed!`n`n" Err.Message '`n' Err.Line '`n' Err.File, 'Version', 0x10)
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