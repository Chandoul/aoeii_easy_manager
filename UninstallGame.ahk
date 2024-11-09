#Include SharedLib.ahk
InstallRegKey := "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Age of Empires II AIO"
AoEIIAIO.Title := 'Age of Empires II AIO Uninstall'
AoEIIAIO.SetFont('Bold')
H := AoEIIAIO.AddButton('xm+95 w200 h40', 'Uninstall')
H.SetFont('s14')
H.OnEvent('Click', UninstallGame)
CreateImageButton(H, 0, [[0xFFFFFF,, 0xFF0000, 4, 0xCCCCCC, 2], [0xE6E6E6], [0xCCCCCC], [0xFFFFFF]]*)
SelectionHistory := IniRead(Config, 'SelectionHistory',, '')
Games := Map()
If A_Args.Length = 1 {
    AoEIIAIO.AddText('xm cBlue', 'The following will be deleted:')
    H := AoEIIAIO.AddCheckbox('Checked', A_Args[1])
    H.OnEvent('Click', UninstallPick)
    Games[A_Args[1]] := [1, H]
} Else {
    Loop Parse, SelectionHistory, '`n', '`r' {
        Location := StrSplit(A_LoopField, '=')[1]
        If A_Index = 1 {
            AoEIIAIO.AddText('xm cBlue', 'Choose which game you want to uninstall:')
        }
        H := AoEIIAIO.AddCheckbox('Checked', Location)
        H.OnEvent('Click', UninstallPick)
        Games[Location] := [1, H]
    }
}
AoEIIAIO.Show('w400')
UninstallPick(Ctrl, Info) {
    Games[Ctrl.Text][1] := Ctrl.Value
}
UninstallGame(Ctrl, Info) {
    Try {
        Ctrl.Text := 'Uninstalling...'
        CreateImageButton(Ctrl, 0, [[0xFFFFFF,, 0xFF0000, 4, 0xCCCCCC, 2], [0xE6E6E6], [0xCCCCCC], [0xFFFFFF]]*)
        Ctrl.Enabled := False
        For Game, Uninstall in Games {
            If !ValidGameDirectory(Game) {
                Msgbox('"' Game '" does not seems to be a valid game location`nUninstall aborted!', 'Uninstall', 0x30)
                Continue
            }
            If Uninstall[1] && 'Yes' = MsgBox('Are you sure want to remove the game loacted at:`n' Game, 'Uninstall', 0x4 + 0x40) {
                DirDelete(Game, 1)
                If IniRead(Config, 'SelectionHistory', Game, 0) {
                    IniDelete(Config, 'SelectionHistory', Game)
                }
                If RegRead(InstallRegKey, 'InstallLocation', '') = Game {
                    RegDeleteKey(InstallRegKey)
                }
                Uninstall[2].Enabled := False
            }
        }
        Ctrl.Text := 'Done!'
        MsgBox('Uninstall complete!', 'Done!', 0x40)
        ExitApp
    } Catch Error As Err {
        MsgBox("Uninstall failed!`n`n" Err.Message '`n' Err.Line '`n' Err.File, 'Language', 0x10)
        Ctrl.Enabled := True
    }
}