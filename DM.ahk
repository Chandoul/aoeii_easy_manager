#Requires AutoHotkey v2
#SingleInstance Force

#Include <WatchOut>
#Include <ScrollBar>
#Include <ImageButton>
#Include <ReadWriteJSON>
#Include <DownloadPackage>
#Include <ExtractPackage>
#Include <ValidGame>
#Include <EnableControl>
#Include <GetConnectedState>
#Include <DMBackup>
#Include <LockCheck>
#Include <IBButtons>

GameDirectory := ReadSetting('Setting.json', 'GameLocation', '')
DMPackage := ReadSetting(, 'DMPackage')

AoEIIAIO := Gui(, 'GAME DATA MODS')
AoEIIAIO.BackColor := 'White'
AoEIIAIO.OnEvent('Close', (*) => ExitApp())
AoEIIAIO.MarginX := AoEIIAIO.MarginY := 10
AoEIIAIO.SetFont('s10', 'Segoe UI')

Features := Map(), Features['DM'] := []
DMList := Map()
DMListH := Map()
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
Search.OnEvent('Change', SearchDM)
Features['DM'].Push(Search)
For ModName, DataMod in DMPackage {
    DMList[ModName] := Map()
    DMListH[Index := Format('{:03}', A_Index)] := Map()
    M := AoEIIAIO.AddButton('xm w460 h40 Right yp+80', '...')
    DMList[ModName]['Title'] := ModName
    DMListH[Index]['Title'] := M
    M.SetFont('Bold s14')
    CreateImageButton(M, 0, [[0xFFFFFF], [0xE6E6E6], [0xCCCCCC], [0xFFFFFF,, 0xCCCCCC]]*)
    Features['DM'].Push(M)
    M := AoEIIAIO.AddButton('xm w460', '...')
    DMList[ModName]['Install'] := 'Install ' ModName
    DMListH[Index]['Install'] := M
    M.SetFont('Bold s10')
    CreateImageButton(M, 0, IBGreen*)
    M.OnEvent('Click', UpdateDM)
    Features['DM'].Push(M)
    M := AoEIIAIO.AddButton('xm w460', '...')
    DMList[ModName]['Update'] := 'Update and Install ' ModName
    DMListH[Index]['Update'] := M
    M.SetFont('Bold s10')
    CreateImageButton(M, 0, IBBlue*)
    M.OnEvent('Click', ClearDM)
    Features['DM'].Push(M)
    M := AoEIIAIO.AddPicture('Border w150 h113')
    DMList[ModName]['Img'] := 'DB\Base\DM\' ModName '.png'
    DMListH[Index]['Img'] := M
    Features['DM'].Push(M)
    Description := DataMod['Description']
    DMList[ModName]['Description'] := Description
    M := AoEIIAIO.AddEdit('ReadOnly -E0x200 yp w300 h113 HScroll -HScroll BackgroundWhite', '...')
    M.SetFont('s8')
    DMList[ModName]['Description'] := Description
    DMListH[Index]['Description'] := M
    Features['DM'].Push(M)
    M := AoEIIAIO.AddButton('xm w460', '...')
    DMList[ModName]['Uninstall'] := 'Uninstall ' ModName
    DMListH[Index]['Uninstall'] := M
    M.SetFont('Bold s10')
    CreateImageButton(M, 0, IBRed*)
    M.OnEvent('Click', UpdateDM)
    Features['DM'].Push(M)
}
AoEIIAIO.Show('w500 h400')
If !ValidGameDirectory(GameDirectory) {
    For Each, Fix in Features['DM']
        Fix.Enabled := False
    If 'Yes' = MsgBox('Game is not yet located!, want to select now?', 'Game', 0x4 + 0x40)
        Run('Game.ahk')
    ExitApp()
}
UpdateModList()
; Updates the data mod list
UpdateModList() {
    For Mod, Prop in DMList {
        ResetDMItem(A_Index)
        DMItemVisible(A_Index)
        DMItemSet(A_Index, Mod, Prop)
    }
}
ResetDMItem(Index, Value := '...') {
    Index := Format('{:03}', Index)
    DMListH[Index]['Title'].Text := Value
    CreateImageButton(DMListH[Index]['Title'], 0, [[0xFFFFFF], [0xE6E6E6], [0xCCCCCC], [0xFFFFFF,, 0xCCCCCC]]*)
    DMListH[Index]['Img'].Value := ''
    DMListH[Index]['Description'].Value := Value
    DMListH[Index]['Install'].Text := Value
    CreateImageButton(DMListH[Index]['Install'], 0, IBGreen*)
    DMListH[Index]['Update'].Text := Value
    CreateImageButton(DMListH[Index]['Update'], 0, IBBlue*)
    DMListH[Index]['Uninstall'].Text := Value
    CreateImageButton(DMListH[Index]['Uninstall'], 0, IBRed*)
}
DMItemVisible(Index, Vis := True) {
    Index := Format('{:03}', Index)
    DMListH[Index]['Title'].Visible := Vis
    DMListH[Index]['Img'].Visible := Vis
    DMListH[Index]['Description'].Visible := Vis
    DMListH[Index]['Install'].Visible := Vis
    DMListH[Index]['Update'].Visible := Vis
    DMListH[Index]['Uninstall'].Visible := Vis
}
DMItemSet(Index, Mod, Prop) {
    Index := Format('{:03}', Index)
    Try DMListH[Index]['Title'].Text := Mod ' ' FileRead(GameDirectory '\Games\' Mod '\version.ini')
    Catch
        DMListH[Index]['Title'].Text := Mod
    CreateImageButton(DMListH[Index]['Title'], 0, [[0xFFFFFF], [0xE6E6E6], [0xCCCCCC], [0xFFFFFF,, 0xCCCCCC]]*)
    DMListH[Index]['Img'].Value := Prop['Img']
    DMListH[Index]['Description'].Value := Prop['Description']
    DMListH[Index]['Install'].Text := Prop['Install']
    CreateImageButton(DMListH[Index]['Install'], 0, IBGreen*)
    DMListH[Index]['Update'].Text := Prop['Update']
    CreateImageButton(DMListH[Index]['Update'], 0, IBBlue*)
    DMListH[Index]['Uninstall'].Text := Prop['Uninstall']
    CreateImageButton(DMListH[Index]['Uninstall'], 0, IBRed*)
}
SearchDM(Ctrl, Info) {
    If !Ctrl.Value {
        UpdateModList()
        Return
    }
    For Prop in DMList {
        ResetDMItem(A_Index)
        DMItemVisible(A_Index, 0)
    }
    Index := 0
    For Mod, Prop in DMList {
        If !InStr(Mod, Search.Value) && !InStr(Prop['Description'], Search.Value) {
            Continue
        }
        Index := Format('{:03}', ++Index)
        DMItemSet(Index, Mod, Prop)
        DMItemVisible(Index)
    }
}
UpdateDM(Ctrl, Info) {
    Switch Type(Ctrl) {
        Case 'Gui.Button':
            P := InStr(Ctrl.Text, ' ')
            Apply := SubStr(Ctrl.Text, 1, P - 1) = 'Install'
            DMName := SubStr(Ctrl.Text, P + 1)
        Case 'String':
            Apply := 1
            DMName := Ctrl
        Default: DMName := '...'
    }
    If DMName = '...' {
        Return
    }
    
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
    Try {
        If Apply {
            If !GetConnectedState() || !DownloadPackages(DMPackage[DMName]['Package']) {
                MsgBox('Unable to install, you either not connected to the internet or a corrupted file was found!', 'Install error!', 0x30)
                Return
            }
            EnableControls(Features['DM'], 0)
            DMBackup(GameDirectory)
            FirstPart := DMPackage[DMName]['Package'][2]
            If FileExist(FirstPart)
                ExtractPackage(FirstPart, 'tmp\' DMName,, 1)
            DMBackup(GameDirectory,, DMName, 2)
            DirCopy('tmp\' DMName, GameDirectory, 1)
            MsgBox(DMName ' - should be installed by now!', 'Data mod', 0x40)
        } Else {
            If FileExist(GameDirectory '\Games\age2_x1.xml') {
                FileDelete(GameDirectory '\Games\age2_x1.xml')
            }
            DMBackup(GameDirectory,,, 1)
            MsgBox(DMName ' - should be uninstalled by now!', 'Data mod', 0x40)
        }
    } Catch {
        If !LockCheck(GameDirectory) {
            EnableControls(Features['DM'])
            MsgBox('Error occured while trying to install ' DMName, 'Error!', 0x10)
            Return
        }
        UpdateDM(Ctrl, Info)
    }
    EnableControls(Features['DM'])
}

ClearDM(Ctrl, Info) {
    EnableControls(Features['DM'], 0)
    DMName := StrReplace(Ctrl.Text, 'Update and Install ')
    If GetConnectedState()
        DownloadPackages(DMPackage[DMName]['Package'], 1)
    If DirExist('tmp\' DMName)
        DirDelete('tmp\' DMName, 1)
    UpdateDM(DMName, Info)
    EnableControls(Features['DM'], 1)
}