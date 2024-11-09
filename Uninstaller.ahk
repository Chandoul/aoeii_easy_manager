#Requires AutoHotkey v2
#SingleInstance Force
; Checks if the script run as admin
If !A_IsAdmin {
    MsgBox('Uninstaller must run as administrator!', 'Warning', 0x30)
    ExitApp
}
InstallRegKey := "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\AoE II AIO"
Uninstaller := Gui('-MinimizeBox', 'Setup')
Uninstaller.OnEvent('Close', (*) => ExitApp())
Try {
    HIcon := LoadPicture('Shell32.dll', 'Icon132')
    Uninstaller.AddPicture(, 'HBITMAP:*' HIcon)
}
Uninstaller.SetFont('Bold s11', 'Calibri')
Uninstaller.AddText('ym+7 cRed', 'Age of Empires II Easy Manager Uninstaller')
UninstallBtn := Uninstaller.AddButton('xm+100 w100', 'Uninstall')
UninstallBtn.OnEvent('Click', Uninstall)
UninstallPrg := Uninstaller.AddProgress('xm -Smooth w300 h17', 100)
Uninstaller.Show()
Uninstall(Ctrl, Info) {
    Try {
        UninstallBtn.Text := 'Uninstalling...'
        UninstallBtn.Enabled := False
        AppDir := RegRead(InstallRegKey, 'InstallLocation', '')
        If !DirExist(AppDir) {
            Return
        }
        P := 0
        Loop Files, AppDir '\*.*', 'DF' {
            P += 1
        }
        UninstallPrg.Opt('Range1-' P)
        Loop Files, AppDir '\*.*', 'DF' {
            UninstallPrg.Value -= 1
            If A_LoopFileName = 'Uninstaller.ahk' {
                Continue
            }
            If InStr(A_LoopFileAttrib, 'D') {
                DirDelete(AppDir '\' A_LoopFileName, 1)
            } Else {
                FileDelete(AppDir '\' A_LoopFileName)
            }
        }
        RegDeleteKey(InstallRegKey)
        If FileExist(A_Desktop '\AoE II Manager AIO.lnk') {
            FileDelete(A_Desktop '\AoE II Manager AIO.lnk')
        }
        Sleep(1000)
        UninstallBtn.Text := 'Uninstalled'
        MsgBox('Uninstallation complete!', 'Setup', 0x40)
        ExitApp()
    } Catch Error As Err {
        MsgBox("Uninstallation failed!`n`n" Err.Message '`n' Err.Line '`n' Err.File, 'Version', 0x10)
    }
}