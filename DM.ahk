#Include SharedLib.ahk
GameLanguage := Map()
Features['DM'] := []
DMList := Map()
DMListH := Map()
AoEIIAIO.Title := 'GAME DATA MODS'
AoEIIAIOSB := ScrollBar(AoEIIAIO, 200, 400)
HotIfWinActive("ahk_id " AoEIIAIO.Hwnd)
Hotkey("WheelUp", (*) => AoEIIAIOSB.ScrollMsg((InStr(A_ThisHotkey,"Down") || InStr(A_ThisHotkey,"Dn")) ? 1 : 0, 0, GetKeyState("Shift") ? 0x114 : 0x115, AoEIIAIO.Hwnd))
Hotkey("WheelDown", (*) => AoEIIAIOSB.ScrollMsg((InStr(A_ThisHotkey,"Down") || InStr(A_ThisHotkey,"Dn")) ? 1 : 0, 0, GetKeyState("Shift") ? 0x114 : 0x115, AoEIIAIO.Hwnd))
Hotkey("+WheelUp", (*) => AoEIIAIOSB.ScrollMsg((InStr(A_ThisHotkey,"Down") || InStr(A_ThisHotkey,"Dn")) ? 1 : 0, 0, GetKeyState("Shift") ? 0x114 : 0x115, AoEIIAIO.Hwnd))
Hotkey("+WheelDown", (*) => AoEIIAIOSB.ScrollMsg((InStr(A_ThisHotkey,"Down") || InStr(A_ThisHotkey,"Dn")) ? 1 : 0, 0, GetKeyState("Shift") ? 0x114 : 0x115, AoEIIAIO.Hwnd))
Hotkey("Up", (*) => AoEIIAIOSB.ScrollMsg((InStr(A_ThisHotkey,"Down") || InStr(A_ThisHotkey,"Dn")) ? 1 : 0, 0, GetKeyState("Shift") ? 0x114 : 0x115, AoEIIAIO.Hwnd))
Hotkey("Down", (*) => AoEIIAIOSB.ScrollMsg((InStr(A_ThisHotkey,"Down") || InStr(A_ThisHotkey,"Dn")) ? 1 : 0, 0, GetKeyState("Shift") ? 0x114 : 0x115, AoEIIAIO.Hwnd))
Hotkey("+Up", (*) => AoEIIAIOSB.ScrollMsg((InStr(A_ThisHotkey,"Down") || InStr(A_ThisHotkey,"Dn")) ? 1 : 0, 0, GetKeyState("Shift") ? 0x114 : 0x115, AoEIIAIO.Hwnd))
Hotkey("+Down", (*) => AoEIIAIOSB.ScrollMsg((InStr(A_ThisHotkey,"Down") || InStr(A_ThisHotkey,"Dn")) ? 1 : 0, 0, GetKeyState("Shift") ? 0x114 : 0x115, AoEIIAIO.Hwnd))
Hotkey("PgUp", (*) => AoEIIAIOSB.ScrollMsg((InStr(A_ThisHotkey,"Down") || InStr(A_ThisHotkey,"Dn")) ? 3 : 2, 0, GetKeyState("Shift") ? 0x114 : 0x115, AoEIIAIO.Hwnd))
Hotkey("PgDn", (*) => AoEIIAIOSB.ScrollMsg((InStr(A_ThisHotkey,"Down") || InStr(A_ThisHotkey,"Dn")) ? 3 : 2, 0, GetKeyState("Shift") ? 0x114 : 0x115, AoEIIAIO.Hwnd))
Hotkey("+PgUp", (*) => AoEIIAIOSB.ScrollMsg((InStr(A_ThisHotkey,"Down") || InStr(A_ThisHotkey,"Dn")) ? 3 : 2, 0, GetKeyState("Shift") ? 0x114 : 0x115, AoEIIAIO.Hwnd))
Hotkey("+PgDn", (*) => AoEIIAIOSB.ScrollMsg((InStr(A_ThisHotkey,"Down") || InStr(A_ThisHotkey,"Dn")) ? 3 : 2, 0, GetKeyState("Shift") ? 0x114 : 0x115, AoEIIAIO.Hwnd))
Hotkey("Home", (*) => AoEIIAIOSB.ScrollMsg(6, 0, GetKeyState("Shift") ? 0x114 : 0x115, AoEIIAIO.Hwnd))
Hotkey("End", (*) => AoEIIAIOSB.ScrollMsg(7, 0, GetKeyState("Shift") ? 0x114 : 0x115, AoEIIAIO.Hwnd))
HotIfWinActive
AoEIIAIO.AddText('Center w460', 'Search')
Search := AoEIIAIO.AddEdit('Border Center -E0x200 w460')
Search.OnEvent('Change', (*) => UpdateList())
Features['DM'].Push(Search)
For Each, DataMod in StrSplit(IniRead('DB\000\DM\DataMod.ini', 'DataMod',, ''), '`n') {
    ModName := StrSplit(DataMod, '=')[1]
    DMList[ModName] := Map()
    DMListH[Index := Format('{:03}', A_Index)] := Map()
    M := AoEIIAIO.AddButton('xm w460 h40 Left', '...')
    DMList[ModName]['Title'] := ModName
    DMListH[Index]['Title'] := M
    M.SetFont('Bold s14')
    CreateImageButton(M, 0, [[0xFFFFFF], [0xE6E6E6], [0xCCCCCC], [0xFFFFFF,, 0xCCCCCC]]*)
    Features['DM'].Push(M)
    M := AoEIIAIO.AddPicture('Border w150 h113')
    DMList[ModName]['Img'] := 'DB\000\DM\' ModName '.png'
    DMListH[Index]['Img'] := M
    Features['DM'].Push(M)
    Description := FileExist('DB\000\DM\' ModName '.txt') ? FileRead('DB\000\DM\' ModName '.txt') : ''
    DMList[ModName]['Description'] := Description
    M := AoEIIAIO.AddEdit('ReadOnly -E0x200 yp w300 h113 HScroll -HScroll BackgroundWhite', '...')
    DMList[ModName]['Description'] := Description
    DMListH[Index]['Description'] := M
    Features['DM'].Push(M)
    M := AoEIIAIO.AddButton('xm w460', '...')
    DMList[ModName]['Install'] := 'Install ' ModName
    DMListH[Index]['Install'] := M
    M.SetFont('Bold s10')
    CreateImageButton(M, 0, [[0xFFFFFF,, 0x008000, 4, 0xCCCCCC, 2], [0xE6E6E6], [0xCCCCCC], [0xFFFFFF]]*)
    M.OnEvent('Click', UpdateDM)
    Features['DM'].Push(M)
    M := AoEIIAIO.AddButton('w460', '...')
    DMList[ModName]['Uninstall'] := 'Uninstall ' ModName
    DMListH[Index]['Uninstall'] := M
    M.SetFont('Bold s10')
    CreateImageButton(M, 0, [[0xFFFFFF,, 0xFF0000, 4, 0xCCCCCC, 2], [0xE6E6E6], [0xCCCCCC], [0xFFFFFF]]*)
    M.OnEvent('Click', UpdateDM)
    Features['DM'].Push(M)
}
AoEIIAIO.Show('w500 h400')
GameDirectory := IniRead(Config, 'Settings', 'GameDirectory', '')
If !ValidGameDirectory(GameDirectory) {
    For Each, Fix in Features['Fixes'] {
        Fix.Enabled := False
    }
    If 'Yes' = MsgBox('Game is not yet located!, want to select now?', 'Game', 0x4 + 0x40) {
        Run('Game.ahk')
    }
    ExitApp()
}
UpdateList()
; Updates the data mod list
UpdateList() {
    For Mod, Prop in DMListH {
        DMListH[Index := Format('{:03}', A_Index)]['Title'].Text := '...'
        CreateImageButton(DMListH[Index]['Title'], 0, [[0xFFFFFF], [0xE6E6E6], [0xCCCCCC], [0xFFFFFF,, 0xCCCCCC]]*)
        DMListH[Index]['Img'].Value := ''
        DMListH[Index]['Description'].Value := '...'
        DMListH[Index]['Install'].Text := '...'
        CreateImageButton(DMListH[Index]['Install'], 0, [[0xFFFFFF,, 0x008000, 4, 0xCCCCCC, 2], [0xE6E6E6], [0xCCCCCC], [0xFFFFFF]]*)
        DMListH[Index]['Uninstall'].Text := '...'
        CreateImageButton(DMListH[Index]['Uninstall'], 0, [[0xFFFFFF,, 0xFF0000, 4, 0xCCCCCC, 2], [0xE6E6E6], [0xCCCCCC], [0xFFFFFF]]*)
    }
    If !Search.Value {
        For Mod, Prop in DMList {
            DMListH[Index := Format('{:03}', A_Index)]['Title'].Text := Mod
            CreateImageButton(DMListH[Index]['Title'], 0, [[0xFFFFFF], [0xE6E6E6], [0xCCCCCC], [0xFFFFFF,, 0xCCCCCC]]*)
            DMListH[Index]['Img'].Value := Prop['Img']
            DMListH[Index]['Description'].Value := Prop['Description']
            DMListH[Index]['Install'].Text := Prop['Install']
            CreateImageButton(DMListH[Index]['Install'], 0, [[0xFFFFFF,, 0x008000, 4, 0xCCCCCC, 2], [0xE6E6E6], [0xCCCCCC], [0xFFFFFF]]*)
            DMListH[Index]['Uninstall'].Text := Prop['Uninstall']
            CreateImageButton(DMListH[Index]['Uninstall'], 0, [[0xFFFFFF,, 0xFF0000, 4, 0xCCCCCC, 2], [0xE6E6E6], [0xCCCCCC], [0xFFFFFF]]*)
        }
        Return
    }
    Index := 0
    For Mod, Prop in DMList {
        If !InStr(Mod, Search.Value) && !InStr(Prop['Description'], Search.Value) {
            Continue
        }
        DMListH[Index := Format('{:03}', ++Index)]['Title'].Text := Mod
        CreateImageButton(DMListH[Index]['Title'], 0, [[0xFFFFFF], [0xE6E6E6], [0xCCCCCC], [0xFFFFFF,, 0xCCCCCC]]*)
        DMListH[Index]['Img'].Value := Prop['Img']
        DMListH[Index]['Description'].Value := Prop['Description']
        DMListH[Index]['Install'].Text := Prop['Install']
        CreateImageButton(DMListH[Index]['Install'], 0, [[0xFFFFFF,, 0x008000, 4, 0xCCCCCC, 2], [0xE6E6E6], [0xCCCCCC], [0xFFFFFF]]*)
        DMListH[Index]['Uninstall'].Text := Prop['Uninstall']
        CreateImageButton(DMListH[Index]['Uninstall'], 0, [[0xFFFFFF,, 0xFF0000, 4, 0xCCCCCC, 2], [0xE6E6E6], [0xCCCCCC], [0xFFFFFF]]*)
    }
}
UpdateDM(Ctrl, Info) {
    Try { 
        P := InStr(Ctrl.Text, ' ')
        Apply := SubStr(Ctrl.Text, 1, P - 1) = 'Install'
        DMName := SubStr(Ctrl.Text, P + 1)
        If DMName = '...' {
            Return
        }
        EnableControls(Features['DM'], 0)
        Update(Ctrl, Progress, Default := 0) {
            If !Default {
                If Apply {
                    Ctrl.Text := 'Installing... ( ' Progress ' % )'
                    CreateImageButton(Ctrl, 0, [[0xFFFFFF,, 0x008000, 4, 0xCCCCCC, 2], [0xE6E6E6], [0xCCCCCC], [0xFFFFFF]]*)
                    Ctrl.Redraw()
                } Else {
                    Ctrl.Text := 'Uninstalling... ( ' Progress ' % )'
                    CreateImageButton(Ctrl, 0, [[0xFFFFFF,, 0xFF0000, 4, 0xCCCCCC, 2], [0xE6E6E6], [0xCCCCCC], [0xFFFFFF]]*)
                    Ctrl.Redraw()
                }
            } Else {
                If Apply {
                    Ctrl.Text := 'Install ' DMName
                    CreateImageButton(Ctrl, 0, [[0xFFFFFF,, 0x008000, 4, 0xCCCCCC, 2], [0xE6E6E6], [0xCCCCCC], [0xFFFFFF]]*)
                    Ctrl.Redraw()
                } Else {
                    Ctrl.Text := 'Uninstall ' DMName
                    CreateImageButton(Ctrl, 0, [[0xFFFFFF,, 0xFF0000, 4, 0xCCCCCC, 2], [0xE6E6E6], [0xCCCCCC], [0xFFFFFF]]*)
                    Ctrl.Redraw()
                }
            }
        }
        If Apply {
            If ConnectedToInternet() {
                ; Tries to download the mod if doesn't exist or it is outdated
                NamePart := IniRead('DB\000\DM\DataMod.ini', 'DataMod', DMName, '')
                If !NamePart {
                    Return
                }
                NamePart := StrSplit(NamePart, '|')
                Parts := StrSplit(NamePart[2], ',')
                PackagesHashs := UpdatedPackagesHashs()
                P := 50 / Parts.Length
                For Each, Part in Parts {
                    Update(Ctrl, P * Each)
                    If FileExist('DB\' NamePart[1] '.7z.' Part)
                    && PackagesHashs.Has('DB\' NamePart[1] '.7z.' Part)
                    && HashFile('DB\' NamePart[1] '.7z.' Part) != PackagesHashs['DB\' NamePart[1] '.7z.' Part] {
                        FileDelete('DB\' NamePart[1] '.7z.' Part)
                    }
                    DownloadPackage('DB/' NamePart[1] '.7z.' Part, 'DB\' NamePart[1] '.7z.' Part, 'DB\' NamePart[1])
                }
            }
            Update(Ctrl, 50)
            If FileExist('DB\' NamePart[1] '.7z.001') {
                ExtractPackage('DB\' NamePart[1] '.7z.001', GameDirectory, 1)
            }
            Update(Ctrl, 100)
            Sleep(1000)
            Update(Ctrl, 100, 1)
        } Else {
            If FileExist(GameDirectory '\Games\age2_x1.xml') {
                FileDelete(GameDirectory '\Games\age2_x1.xml')
            }
            Update(Ctrl, 100)
            Sleep(1000)
            Update(Ctrl, 100, 1)
        }
        EnableControls(Features['DM'])
    } Catch Error As Err {
        MsgBox("Select failed!`n`n" Err.Message '`n' Err.Line '`n' Err.File, 'Fix', 0x10)
        Ctrl.Enabled := True
    }
}