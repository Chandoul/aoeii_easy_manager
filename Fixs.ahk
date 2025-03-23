#Requires AutoHotkey v2
#SingleInstance Force

#Include <WatchOut>
#Include <ReadWriteJSON>
#Include <ImageButton>
#Include <ValidGame>
#Include <LockCheck>
#Include <DefaultPB>
#Include <EnableControl>
#Include <HashFile>
#Include <DownloadPackage>
#Include <ExtractPackage>
#Include <IBButtons>
#Include <VersionExist>

AoEIIAIO := Gui(, 'GAME FIXS')
AoEIIAIO.BackColor := 'White'
AoEIIAIO.OnEvent('Close', (*) => ExitApp())
AoEIIAIO.MarginX := AoEIIAIO.MarginY := 10
AoEIIAIO.SetFont('s10', 'Segoe UI')

GameFix := ReadSetting(, 'GameFix')
RegKey := ReadSetting(, 'GameFixREG')
RegName := ReadSetting(, 'GameFixREGName')
FixPackage := ReadSetting(, 'FixPackage')

Features := Map(), Features['Fixs'] := []

H := AoEIIAIO.AddText('w350 Center h25', 'Select one of the fixes below')
H.SetFont('Bold')
AoEIIAIO.SetFont('s9')
For Each, FIX in GameFix['FIX'] {
    H := AoEIIAIO.AddButton('w350', FIX)
    H.SetFont('Bold')
    CreateImageButton(H, 0, IBBlack*)
    Features['Fixs'].Push(H)
    H.OnEvent('Click', ApplyFix)
    GameFix['FIXHandle'][FIX] := H
}
H := AoEIIAIO.AddLink('w350', 'Help Links:`n<a href="https://www.moddb.com/games/age-of-empires-2-the-conquerors/downloads/aoe2-patch-wide-screen-1010c2020a20b-20c">Aoe2 Patch Wide Screen 1.0, 1.0c, 2.0, 2.0a, 2.0b, 2.0c</a>'
    . '`n<a href="https://aok.heavengames.com/blacksmith/showfile.php?fileid=13275">Aoe II Wide Screen all version</a>'
    . '`n<a href="https://aok.heavengames.com/blacksmith/showfile.php?fileid=13710">Age of Empire II the Age of king version 2.0c patch into 2.0</a>'
    . '`n<a href="https://aok.heavengames.com/blacksmith/showfile.php?fileid=13730">Ao2 patch:1.0 ,1.0c,2.0,2.0a,2.0c Widescreen + windowed</a>'
    . '`n<a href="https://aok.heavengames.com/blacksmith/showfile.php?fileid=13673">Aok 2.0 Generate Record To Ignore Player Who Leave</a>')
H.SetFont('Bold')
AoEIIAIO.AddText('ym w300', 'Options').SetFont('Bold')
GeneralOptions := AoEIIAIO.AddListView('r4 -Hdr Checked -E0x200 wp', [' ', ' '])
For Option in StrSplit(IniRead('DB\Fix\general.ini', 'General', , ''), '`n') {
    OptionValue := StrSplit(Option, '=')
    CurrentValue := RegRead(RegKey, RegName, 0)
    GeneralOptions.Add(CurrentValue = OptionValue[2] ? 'Check' : '', IniRead('DB\Fix\general.ini', 'Description', OptionValue[1], ''), OptionValue[1])
    GeneralOptions.ModifyCol(1, 'AutoHdr')
}
GeneralOptions.ModifyCol(2, '0')
GeneralOptions.OnEvent('ItemCheck', UpdateAoe2Patch)
UpdateAoe2Patch(Ctrl, Item, Checked) {
    Loop GeneralOptions.GetCount() {
        GeneralOptions.Modify(A_Index, '-Check')
    }
    GeneralOptions.Modify(Item, 'Check')
    RegWrite(Item, 'REG_DWORD', RegKey, RegName)
}
WaterAni := AoEIIAIO.AddCheckBox('xp+4 yp+80 ' (RegRead(RegKey, 'WaterAnnimation', 0) ? 'Checked' : ''), ' Water animation')
WaterAni.OnEvent('Click', UpdateAoe2PatchWA)
UpdateAoe2PatchWA(Ctrl, Info) {
    RegWrite(Ctrl.Value, 'REG_DWORD', RegKey, 'WaterAnnimation')
}
WindModeCheck() {
    RC := 0
    RC += FileExist(GameDirectory '\windmode.dll') ? 1 : 0
    RC += FileExist(GameDirectory '\age2_x1\wndmode.dll') ? 1 : 0
    RC += FileExist(GameDirectory '\age2_x1\windmode.dll') ? 1 : 0
    Return RC
}
WndOpt := AoEIIAIO.AddCheckbox('xp yp+30 w300', 'Window mod')
WndOpt.SetFont('Bold')
WndOpt.OnEvent('Click', OnOffWndOpt)
OnOffWndOpt(Ctrl, Info) {
    AdvanceOptions.Enabled := Ctrl.Value ? 1 : 0
}
AdvanceOptions := AoEIIAIO.AddListView('xp-4 yp+20 r10 -Hdr Checked -E0x200 wp', [' '])
For Option in StrSplit(IniRead('DB\Fix\wndmode.ini', 'WINDOWMODE', , ''), '`n') {
    OptionValue := StrSplit(Option, '=')
    AdvanceOptions.Add(OptionValue[2] ? 'Check' : '', OptionValue[1])
    AdvanceOptions.ModifyCol(1, 'AutoHdr')
}
AdvanceOptions.OnEvent('ItemCheck', UpdateWndMod)
UpdateWndMod(Ctrl, Item, Checked) {
    CurrentKey := AdvanceOptions.GetText(Item)
    IniWrite(Checked, 'DB\Fix\wndmode.ini', 'WINDOWMODE', CurrentKey)
    Configs := [GameDirectory '\wndmode.ini', GameDirectory '\age2_x1\wndmode.ini']
    For Config in Configs {
        If !FileExist(Config) {
            FileAppend("", Config, "UTF-8")
        }
        Checked ? IniWrite(1, Config, 'WINDOWMODE', CurrentKey) : IniDelete(Config, 'WINDOWMODE', CurrentKey)
    }
}
AoEIIAIO.Show()
GameDirectory := ReadSetting('Setting.json', 'GameLocation', '')
RC := WindModeCheck()
WndOpt.Value := RC = 3 ? 1 : 0
OnOffWndOpt(WndOpt, '')

If A_Args.Length {
    ApplyFix(GameFix['FIXHandle'][A_Args[1]], '')
    SetTimer(Quit, -1000)
    MsgBox('Fix applied successfully!', 'Fix', 0x40)
    Quit() {
        ExitApp()
    }
}

If !ValidGameDirectory(GameDirectory) {
    For Each, Fix in Features['Fixs'] {
        Fix.Enabled := False
    }
    If 'Yes' = MsgBox('Game is not yet located!, want to select now?', 'Game', 0x4 + 0x40) {
        Run('Game.ahk')
    }
    ExitApp()
}
AnalyzeFix()
; Applys fixes
ApplyFix(Ctrl, Info) {
    Try {
        If Ctrl.Text = 'Fix v0' {
            If VersionExist('aoc', '1.0', GameDirectory) {
                RunWait('"DB\Fix\Fix v0\Patcher.exe" "' GameDirectory '\age2_x1\age2_x1.exe" "DB\Fix\Fix v0\AoC_10.patch"', , 'Hide')
                FileDelete('*.ws')
            } Else If VersionExist('aoc', '1.0c', GameDirectory) || VersionExist('aoc', '1.0e', GameDirectory) {
                RunWait('"DB\Fix\Fix v0\Patcher.exe" "' GameDirectory '\age2_x1\age2_x1.exe" "DB\Fix\Fix v0\AoC_10ce.patch"', , 'Hide')
                FileDelete('*.ws')
            } Else Return
            EnableControls(Features['Fixs'], 0)
            FileMove(GameDirectory '\age2_x1\age2_x1_' A_ScreenWidth 'x' A_ScreenHeight '.exe', GameDirectory '\age2_x1\age2_x1.exe', 1)
            DirCopy('DB\Fix\Fix v0\Bmp\', 'DB\Fix\Fix v0\', 1)
            RunWait("DB\Fix\Fix v0\ResizeFrames.exe", 'DB\Fix\Fix v0', 'Hide')
            Loop Files 'DB\Fix\Fix v0\int*.bmp' {
                RunWait('"DB\Fix\Fix v0\Bmp2Slp.exe" "' A_LoopFileFullPath '"', , 'Hide')
            }

            DRSBuild := '"DB\Fix\Fix v0\DrsBuild.exe"'
            DRSRef := Format('{:05}', A_ScreenWidth) Format('{:04}', A_ScreenHeight)

            FileCopy(GameDirectory '\Data\interfac.drs', GameDirectory '\Data\interfac_.drs', 1)
            RunWait(DRSBuild ' /r "' GameDirectory '\Data\interfac_.drs" "DB\Fix\Fix v0\*.slp"', , 'Hide')
            FileMove(GameDirectory '\Data\interfac_.drs', GameDirectory '\Data\' DRSRef '.ws', 1)
            FileDelete('DB\Fix\Fix v0\*.bmp')
            FileDelete('DB\Fix\Fix v0\*.slp')
            EnableControls(Features['Fixs'])
            SoundPlay('DB\Base\30 Wololo.mp3')
            Return
        }
        If Ctrl.Text = 'None' {
            EnableControls(Features['Fixs'], 0)
            DefaultPB(Features['Fixs'], IBBlack)
            CleansUp()
            AnalyzeFix()
            EnableControls(Features['Fixs'])
            SoundPlay('DB\Base\30 Wololo.mp3')
            Return
        }
        If VersionExist('aoc', '1.0e', GameDirectory)
            || VersionExist('aoc', '1.1', GameDirectory) {
                Msgbox('Sorry to inform you that ' Ctrl.Text ' does not apply on the current version your game is running! (1.0e, 1.5)', 'Incompatible!', 0x30)
                Return
        }
        EnableControls(Features['Fixs'], 0)
        DefaultPB(Features['Fixs'], IBBlack)
        CleansUp()
        DirCopy('DB\Fix\' Ctrl.Text, GameDirectory, 1)
        EnableControls(Features['Fixs'])
        AnalyzeFix()
        SoundPlay('DB\Base\30 Wololo.mp3')
    } Catch {
        If !LockCheck(GameDirectory) {
            EnableControls(Features['Fixs'])
            Return
        }
        ApplyFix(Ctrl, Info)
    }
}
AnalyzeFix() {
    MatchFix := ''
    Loop Files, 'DB\Fix\*', 'D' {
        Fix := A_LoopFileName
        If Fix = 'Fix v0' {
            Continue
        }
        Match := True
        Loop Files, 'DB\Fix\' Fix '\*.*', 'R' {
            PathFile := StrReplace(A_LoopFileDir '\' A_LoopFileName, 'DB\Fix\' Fix '\')
            If !FileExist(GameDirectory '\' PathFile) && Match {
                Match := False
                Break
            }
            CurrentHash := HashFile(A_LoopFileFullPath)
            FoundHash := HashFile(GameDirectory '\' PathFile)
            If (CurrentHash != FoundHash) && Match {
                Match := False
                Break
            }
        }
        If Match {
            MatchFix := Fix
        }
    }
    If MatchFix {
        CreateImageButton(GameFix['FIXHandle'][MatchFix], 0, IBGreen1*)
        GameFix['FIXHandle'][MatchFix].Redraw()
    }
}
; Cleans up
CleansUp() {
    Loop Files, 'DB\Fix\*', 'D' {
        Fix := A_LoopFileName
        Loop Files, 'DB\Fix\' Fix '\*.*', 'R' {
            PathFile := StrReplace(A_LoopFileDir '\' A_LoopFileName, 'DB\Fix\' Fix '\')
            If FileExist(GameDirectory '\' PathFile) {
                FileDelete(GameDirectory '\' PathFile)
            }
        }
    }
}