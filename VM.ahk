#Requires AutoHotkey v2
#SingleInstance Force

#Include <ScrollBar>
#Include <ImageButton>
#Include <ReadWriteJSON>
#Include <ValidGame>
#Include <EnableControl>
#Include <ExtractPackage>
#Include <DownloadPackage>

GameDirectory := ReadSetting('Setting.json', 'GameLocation')
DrsMap := ReadSetting(, 'DrsMap')
VMPackage := ReadSetting(, 'VMPackage')

AoEIIAIO := Gui(, 'GAME VISUAL MODS')
AoEIIAIO.BackColor := 'White'
AoEIIAIO.OnEvent('Close', (*) => ExitApp())
AoEIIAIO.MarginX := AoEIIAIO.MarginY := 10
AoEIIAIO.SetFont('s10', 'Calibri')

Try DownloadPackages(VMPackage), ExtractPackage(VMPackage[2], 'DB\007',, 1)
Catch {
    MsgBox('Sorry!, something went wrong!', 'Error', 0x30)
    ExitApp()
}

Features := Map(), Features['VM'] := []
VMList := Map()
VMListH := Map()
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
Search.OnEvent('Change', (*) => UpdateModList())
Features['VM'].Push(Search)
Loop Files, 'DB\007\*', 'D' {
    VMList[A_LoopFileName] := Map()
    VMListH[Index := Format('{:03}', A_Index)] := Map()
    M := AoEIIAIO.AddButton('xm w460 h40 Left', '...')
    VMList[A_LoopFileName]['Title'] := A_LoopFileName
    VMListH[Index]['Title'] := M
    M.SetFont('Bold s14')
    CreateImageButton(M, 0, [[0xFFFFFF], [0xE6E6E6], [0xCCCCCC], [0xFFFFFF,, 0xCCCCCC]]*)
    Features['VM'].Push(M)
    M := AoEIIAIO.AddPicture('Border w150 h113')
    VMList[A_LoopFileName]['Img'] := 'DB\007\' A_LoopFileName '\img.png'
    VMListH[Index]['Img'] := M
    Features['VM'].Push(M)
    Description := FileExist('DB\007\' A_LoopFileName '\Info.txt') ? FileRead('DB\007\' A_LoopFileName '\Info.txt') : ''
    VMList[A_LoopFileName]['Description'] := Description
    M := AoEIIAIO.AddEdit('ReadOnly -E0x200 yp w300 h113 HScroll -HScroll BackgroundWhite', '...')
    VMList[A_LoopFileName]['Description'] := Description
    VMListH[Index]['Description'] := M
    Features['VM'].Push(M)
    M := AoEIIAIO.AddButton('xm w460', '...')
    VMList[A_LoopFileName]['Install'] := 'Install ' A_LoopFileName
    VMListH[Index]['Install'] := M
    M.SetFont('Bold s10')
    CreateImageButton(M, 0, [[0xFFFFFF,, 0x008000, 4, 0xCCCCCC, 2], [0xE6E6E6], [0xCCCCCC], [0xFFFFFF]]*)
    M.OnEvent('Click', UpdateVM)
    Features['VM'].Push(M)
    M := AoEIIAIO.AddButton('w460', '...')
    VMList[A_LoopFileName]['Uninstall'] := 'Uninstall ' A_LoopFileName
    VMListH[Index]['Uninstall'] := M
    M.SetFont('Bold s10')
    CreateImageButton(M, 0, [[0xFFFFFF,, 0xFF0000, 4, 0xCCCCCC, 2], [0xE6E6E6], [0xCCCCCC], [0xFFFFFF]]*)
    M.OnEvent('Click', UpdateVM)
    Features['VM'].Push(M)
}
AoEIIAIO.Show('w500 h400')
If !ValidGameDirectory(GameDirectory) {
    For Each, Fix in Features['VM'] {
        Fix.Enabled := False
    }
    If 'Yes' = MsgBox('Game is not yet located!, want to select now?', 'Game', 0x4 + 0x40) {
        Run('Game.ahk')
    }
    ExitApp()
}
UpdateModList()
; Updates the list
UpdateModList() {
    For Mod, Prop in VMListH {
        VMListH[Index := Format('{:03}', A_Index)]['Title'].Text := '...'
        CreateImageButton(VMListH[Index]['Title'], 0, [[0xFFFFFF], [0xE6E6E6], [0xCCCCCC], [0xFFFFFF,, 0xCCCCCC]]*)
        VMListH[Index]['Img'].Value := ''
        VMListH[Index]['Description'].Value := '...'
        VMListH[Index]['Install'].Text := '...'
        CreateImageButton(VMListH[Index]['Install'], 0, [[0xFFFFFF,, 0x008000, 4, 0xCCCCCC, 2], [0xE6E6E6], [0xCCCCCC], [0xFFFFFF]]*)
        VMListH[Index]['Uninstall'].Text := '...'
        CreateImageButton(VMListH[Index]['Uninstall'], 0, [[0xFFFFFF,, 0xFF0000, 4, 0xCCCCCC, 2], [0xE6E6E6], [0xCCCCCC], [0xFFFFFF]]*)
    }
    If !Search.Value {
        For Mod, Prop in VMList {
            VMListH[Index := Format('{:03}', A_Index)]['Title'].Text := Mod
            CreateImageButton(VMListH[Index]['Title'], 0, [[0xFFFFFF], [0xE6E6E6], [0xCCCCCC], [0xFFFFFF,, 0xCCCCCC]]*)
            VMListH[Index]['Img'].Value := Prop['Img']
            VMListH[Index]['Description'].Value := Prop['Description']
            VMListH[Index]['Install'].Text := Prop['Install']
            CreateImageButton(VMListH[Index]['Install'], 0, [[0xFFFFFF,, 0x008000, 4, 0xCCCCCC, 2], [0xE6E6E6], [0xCCCCCC], [0xFFFFFF]]*)
            VMListH[Index]['Uninstall'].Text := Prop['Uninstall']
            CreateImageButton(VMListH[Index]['Uninstall'], 0, [[0xFFFFFF,, 0xFF0000, 4, 0xCCCCCC, 2], [0xE6E6E6], [0xCCCCCC], [0xFFFFFF]]*)
        }
        Return
    }
    Index := 0
    For Mod, Prop in VMList {
        If !InStr(Mod, Search.Value) && !InStr(Prop['Description'], Search.Value) {
            Continue
        }
        VMListH[Index := Format('{:03}', ++Index)]['Title'].Text := Mod
        CreateImageButton(VMListH[Index]['Title'], 0, [[0xFFFFFF], [0xE6E6E6], [0xCCCCCC], [0xFFFFFF,, 0xCCCCCC]]*)
        VMListH[Index]['Img'].Value := Prop['Img']
        VMListH[Index]['Description'].Value := Prop['Description']
        VMListH[Index]['Install'].Text := Prop['Install']
        CreateImageButton(VMListH[Index]['Install'], 0, [[0xFFFFFF,, 0x008000, 4, 0xCCCCCC, 2], [0xE6E6E6], [0xCCCCCC], [0xFFFFFF]]*)
        VMListH[Index]['Uninstall'].Text := Prop['Uninstall']
        CreateImageButton(VMListH[Index]['Uninstall'], 0, [[0xFFFFFF,, 0xFF0000, 4, 0xCCCCCC, 2], [0xE6E6E6], [0xCCCCCC], [0xFFFFFF]]*)
    }
}
; Updates a game visual mod
UpdateVM(Ctrl, Info) {
    Try {
        P := InStr(Ctrl.Text, ' ')
        Apply := SubStr(Ctrl.Text, 1, P - 1) = 'Install'
        VMName := SubStr(Ctrl.Text, P + 1)
        If VMName = '...' {
            Return
        }
        EnableControls(Features['VM'], 0)
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
                    Ctrl.Text := 'Install ' VMName
                    CreateImageButton(Ctrl, 0, [[0xFFFFFF,, 0x008000, 4, 0xCCCCCC, 2], [0xE6E6E6], [0xCCCCCC], [0xFFFFFF]]*)
                    Ctrl.Redraw()
                } Else {
                    Ctrl.Text := 'Uninstall ' VMName
                    CreateImageButton(Ctrl, 0, [[0xFFFFFF,, 0xFF0000, 4, 0xCCCCCC, 2], [0xE6E6E6], [0xCCCCCC], [0xFFFFFF]]*)
                    Ctrl.Redraw()
                }
            }
        }
        Update(Ctrl, 0)
        ; Update the slp
        WorkDir := Apply ? 'DB\007\' VMName : 'DB\007\' VMName '\U'
        If FileExist(WorkDir '\gra*.slp') || FileExist(WorkDir '\int*.slp') || FileExist(WorkDir '\ter*.slp') {
            RunWait('DB\000\DrsBuild.exe /a "' GameDirectory '\Data\' DrsMap['gra'] '" "' WorkDir '\gra*.slp"',, 'Hide')
            RunWait('DB\000\DrsBuild.exe /a "' GameDirectory '\Data\' DrsMap['int'] '" "' WorkDir '\int*.slp"',, 'Hide')
            RunWait('DB\000\DrsBuild.exe /a "' GameDirectory '\Data\' DrsMap['ter'] '" "' WorkDir '\ter*.slp"',, 'Hide')
        }
        Update(Ctrl, 60)
        ; Update the bina
        If FileExist(WorkDir '\Info.ini') {
            Drs := IniRead(WorkDir '\Info.ini', 'Info', 'Drs', '')
            FileN := IniRead(WorkDir '\Info.ini', 'Info', 'File', '')
            Lines := StrSplit(IniRead(WorkDir '\Info.ini', 'Info', 'Line', ''), ',')
            Values := StrSplit(IniRead(WorkDir '\Info.ini', 'Info', 'Value', ''), ',')
            RunWait('DB\000\DrsBuild.exe /e "' GameDirectory '\Data\' Drs '" ' FileN ' /o "' GameDirectory '\Data"',, 'Hide')
            OBJ := FileOpen(GameDirectory '\Data\' FileN, 'r')
            NValues := Map()
            While !OBJ.AtEOF {
                Index := Format('{:03}', A_Index)
                NValues[Index] := OBJ.ReadLine()
            }
            OBJ.Close()
            For Index, Line in Lines {
                NValues[Line] := Values[Index]
            }
            OBJ := FileOpen(GameDirectory '\Data\' FileN, 'w')
            For Index, Line in NValues {
                OBJ.WriteLine(Line)
            }
            OBJ.Close()
            RunWait('DB\000\DrsBuild.exe /a "' GameDirectory '\Data\' Drs '" "' GameDirectory '\Data\' FileN '"',, 'Hide')
            FileDelete(GameDirectory '\Data\' FileN)
        }
        ; Copy files
        CopyFolder := Apply ? 'DB\007\' VMName '\Install' : 'DB\007\' VMName '\Uninstall'
        If DirExist(CopyFolder) {
            ; Clean existing files
            Loop Files, CopyFolder '\*', 'RFD' {
                PathFile := StrReplace(A_LoopFileDir '\' A_LoopFileName, CopyFolder '\')
                If InStr(A_LoopFileAttrib, 'D') {
                    If DirExist(GameDirectory '\' PathFile) {
                        DirDelete(GameDirectory '\' PathFile, 1)
                    }
                } Else If FileExist(GameDirectory '\' PathFile) {
                    FileDelete(GameDirectory '\' PathFile)
                }
            }
            ; Apply the new files
            DirCopy(CopyFolder, GameDirectory, 1)
        }
        Update(Ctrl, 80)
        ; Update the external game data slp
        If FileExist(GameDirectory '\Games\age2_x1.xml') {
            If RegExMatch(FileRead(GameDirectory '\Games\age2_x1.xml'), '\Q<path>\E(.*)\Q</path>\E', &DName) {
                RunWait('DB\000\DrsBuild.exe /a "' GameDirectory '\Games\' DName[1] '\Data\gamedata_x1_p1.drs" "' WorkDir '\*.slp"',, 'Hide')
            }
        }
        Update(Ctrl, 100)
        Sleep(1000)
        Update(Ctrl, 100, 1)
        EnableControls(Features['VM'])
    } Catch Error As Err {
        EnableControls(Features['VM'])
        MsgBox("Update failed!`n`n" Err.Message '`n' Err.Line '`n' Err.File, 'Visual mod', 0x10)
    }
    EnableControls(Features['VM'])
}