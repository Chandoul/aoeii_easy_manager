#Requires AutoHotkey v2
#SingleInstance Force
GR := A_AppData '\GameRanger\GameRanger\GameRanger.exe'
GRS := A_AppData '\GameRanger\GameRanger Prefs\Settings'
If !FileExist(GR) {
    Msgbox 'You must install GameRanger first!', T, 0x30
    ExitApp
}
Setting := A_AppData '\GR Account Switcher'
SettingBak := A_AppData '\GR Account Switcher\Backup'
SettingIni := A_AppData '\GR Account Switcher\Setting.ini'
If !DirExist(SettingBak) {
    DirCreate(SettingBak)
}
Window := Gui(, T := 'GR Account Switcher')
Window.BackColor := 'White'
Window.MarginX := 10
Window.MarginY := 10
Window.OnEvent('Close', (*) => ExitApp())
Window.SetFont('s10 Bold', 'Segoe UI')
AccList := Window.AddListView('w300 r10 cBlue', ['Account'])
Window.SetFont('s8 norm')
AccAdd  := Window.AddButton('w150', 'Add')
AccRem  := Window.AddButton('xp+150 yp w150', 'Remove')
Window.SetFont('s12 Bold')
AccLog  := Window.AddButton('xm w300', '→ Login')
Window.SetFont('s10 Bold')
AccRes  := Window.AddButton('xm w300', '→ Restart')
Window.SetFont('s10 norm')
AccCre  := Window.AddButton('xm w300', '+ Create New')
Window.Show()
UpdateList()

AccRes.OnEvent('Click', ResAccount)
ResAccount(Ctrl, Info) {
    ProcessClose('GameRanger.exe')
    ProcessWaitClose('GameRanger.exe')
    Run(GR)
}
; Add a new profile
AccAdd.OnEvent('Click', AddAccount)
AddAccount(Ctrl, Info) {
    Result := ProfileAdd()
    If !Result {
        Return
    }
    FileCopy(GRS, Setting '\' Result)
    AccList.Add(, Result)
    Msgbox('Profile should be added by now!', T, 0x40)
}
; Remove a profile
AccRem.OnEvent('Click', RemAccount)
RemAccount(Ctrl, Info) {
    If !R := AccList.GetNext() {
        Return
    }
    Result := StrReplace(AccList.GetText(R), ' ← [ Last Login ]', '.Logged')
    If 'Yes' = MsgBox('Are you sure to remove this profile?', T, 0x40 + 0x4) {
        FileDelete(Setting '\' Result)
        AccList.Delete(R)
        Msgbox('Profile should be removed by now!', T, 0x40)
    }
}
; Login to a profile
AccLog.OnEvent('Click', LogAccount)
LogAccount(Ctrl, Info) {
    If !R := AccList.GetNext() {
        Return
    }
    Result := StrReplace(AccList.GetText(R), ' ← [ Last Login ]')
    Loop Files Setting '\*' {
        If A_LoopFileExt = 'Logged' {
            FileMove(Setting '\' A_LoopFileName, Setting '\' SubStr(A_LoopFileName, 1, -7))
        }
    }
    FileMove(Setting '\' Result, Setting '\' Result '.Logged')
    FileCopy(Setting '\' Result '.Logged', GRS, 1)
    Loop AccList.GetCount() {
        Name := StrReplace(AccList.GetText(A_Index), ' ← [ Last Login ]')
        If R != A_Index
            AccList.Modify(A_Index,, Name)
        Else {
            AccList.Modify(A_Index,, Name ' ← [ Last Login ]')
        }
    }
    ProcessClose('GameRanger.exe')
    ProcessWaitClose('GameRanger.exe')
    Run(GR)
}
; Create new account
AccCre.OnEvent('Click', CreAccount)
CreAccount(Ctrl, Info) {
    ProcessClose('GameRanger.exe')
    ProcessWaitClose('GameRanger.exe')
    FileMove(GRS, SettingBak '\' A_Now)
    Run(GR)
}
ProfileAdd() {
    Loop {
        OK := False
        Choice := InputBox('Please provide a name for your current account', T, 'w400 h120', 'Account name example!')
        If Choice.Result = 'OK'{
            If Choice.Value = '' || FileExist(Setting '\' Choice.Value) {
                MsgBox("The profile name must not be (empty or already exist)!", T, 0x30)
            } Else OK := True  
        } Else OK := True
    } Until OK
    If Choice.Result != 'OK'
        Return
    Return Choice.Value
}
ReadLoggedProfile() {
    Loop Files Setting '\*'
        If A_LoopFileExt = 'Logged'
            Return A_LoopFileName
    Return
}
UpdateList() {
    Logged := ReadLoggedProfile()
    Loop Files Setting '\*' {
        If A_LoopFileName = Logged
            AccList.Add(, SubStr(A_LoopFileName, 1, -7) ' ← [ Last Login ]')
        Else AccList.Add(, A_LoopFileName)
    }
    AccList.ModifyCol(1, 'AutoHdr')
}
ProfileAlreadyExist(Name) {
    Return Name != '' && FileExist(Setting '\' Name)
}
ProfileCount() {
    C := 0
    Loop Files Setting '\*'
        ++C
    Return C
}