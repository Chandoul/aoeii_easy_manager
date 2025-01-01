#Requires AutoHotkey v2
#SingleInstance Force

#Include <WatchOut>
#Include <ImageButton>
#Include <ReadWriteJSON>
#Include <ValidGame>
#Include <HashFile>
#Include <DefaultPB>
#Include <EnableControl>
#Include <LockCheck>
#Include <DownloadPackage>
#Include <ExtractPackage>
#Include <IBButtons>
#Include <ScrollBar>

GameDirectory := ReadSetting('Setting.json', 'GameLocation', '')
LngPackage := ReadSetting(, 'LngPackage', [])

AoEIIAIO := Gui(, 'GAME INTERFACE LANGUAGES')
AoEIIAIO.BackColor := 'White'
AoEIIAIO.OnEvent('Close', (*) => ExitApp())
AoEIIAIO.MarginX := AoEIIAIO.MarginY := 10
AoEIIAIO.SetFont('s10 Bold', 'Segoe UI')
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
GameLanguage := Map()
Features := Map(), Features['Language'] := []
Index := 0
Loop Files, 'DB\Lng\*', 'D' {
    If (A_LoopFileName ~= 'Flags')
        Continue
    ++Index
    H := AoEIIAIO.AddButton('xm w200', A_LoopFileName)
    H1 := AoEIIAIO.AddPicture('xp+210 yp+1 Border', 'DB\Lng\Flags\' A_LoopFileName '.png')
    CreateImageButton(H, 0, IBGray*)
    Features['Language'].Push(H)
    H.OnEvent('Click', ApplyLanguage)
    H1.OnEvent('Click', ApplyLanguage)
    GameLanguage[A_LoopFileName] := H
}
AoEIIAIO.Show('w300 h400')
If !ValidGameDirectory(GameDirectory) {
    For Each, Version in Features['Language'] {
        Version.Enabled := False
    }
    If 'Yes' = MsgBox('Game is not yet located!, want to select now?', 'Game', 0x4 + 0x40) {
        Run('Game.ahk')
    }
    ExitApp()
}
AnalyzeLanguage()
; Aanalyzes game languages
AnalyzeLanguage() {
    MatchLanguage := ''
    Loop Files, 'DB\Lng\*', 'D' {
        Language := A_LoopFileName
        Match := True
        Loop Files, 'DB\Lng\' Language '\*.*', 'R' {
            PathFile := StrReplace(A_LoopFileDir '\' A_LoopFileName, 'DB\Lng\' Language '\')
            If !FileExist(GameDirectory '\' PathFile) {
                Match := False
                Break
            }
            If HashFile(A_LoopFileFullPath) != HashFile(GameDirectory '\' PathFile) {
                Match := False
                Break
            }
        }
        If Match {
            MatchLanguage := Language
            CreateImageButton(GameLanguage[MatchLanguage], 0, IBGreen*)
            GameLanguage[MatchLanguage].Redraw()
        }
    }
}
CleanUp() {
    Loop Files, 'DB\Lng\*', 'D' {
        Language := A_LoopFileName
        Loop Files, 'DB\Lng\' Language '\*.*', 'R' {
            PathFile := StrReplace(A_LoopFileDir '\' A_LoopFileName, 'DB\Lng\' Language '\')
            If FileExist(GameDirectory '\' PathFile) {
                FileDelete(GameDirectory '\' PathFile)
            }
        }
    }
}
ApplyLanguage(Ctrl, Info) {
    Try {
        If Type(Ctrl) = 'Gui.Pic' {
            SplitPath(Ctrl.Text,,,, &Language)
        } Else Language := Ctrl.Text
        EnableControls(Features['Language'], 0)
        DefaultPB(Features['Language'], IBGray)
        CleanUp()
        DirCopy('DB\Lng\' Language, GameDirectory, 1)
        AnalyzeLanguage()
        EnableControls(Features['Language'])
        SoundPlay('DB\Base\30 Wololo.mp3')
    } Catch {
        If !LockCheck(GameDirectory) {
            EnableControls(Features['Language'])
            MsgBox('Error occured while trying to install ' Language, 'Error!', 0x10)
            Return
        }
        ApplyLanguage(Ctrl, Info) 
    }
}