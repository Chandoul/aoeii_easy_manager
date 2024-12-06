#Requires AutoHotkey v2
#SingleInstance Force

#Include <WatchOut>
#Include <ReadWriteJSON>
#Include <ImageButton>
#Include <ValidGame>
#Include <CloseGame>
#Include <DefaultPB>
#Include <EnableControl>
#Include <HashFile>
#Include <DownloadPackage>
#Include <ExtractPackage>

AoEIIAIO := Gui(, 'GAME FIXS')
AoEIIAIO.BackColor := 'White'
AoEIIAIO.OnEvent('Close', (*) => ExitApp())
AoEIIAIO.MarginX := AoEIIAIO.MarginY := 10
AoEIIAIO.SetFont('s10', 'Calibri')

GameFix := ReadSetting(, 'GameFix')
RegKey := ReadSetting(, 'GameFixREG')
RegName := ReadSetting(, 'GameFixREGName')
FixPackage := ReadSetting(, 'FixPackage')

Try DownloadPackage(FixPackage[1], FixPackage[2]), ExtractPackage(FixPackage[2], 'DB\001',, 1)
Catch {
    MsgBox('Sorry!, something went wrong!', 'Error', 0x30)
    ExitApp()
}

Features := Map(), Features['Fixs'] := []

H := AoEIIAIO.AddText('w350 Center h25', 'Select one of the fixes below')
H.SetFont('Bold s12')
For Each, FIX in GameFix['FIX'] {
    H := AoEIIAIO.AddButton('w350', FIX)
    H.SetFont('Bold')
    CreateImageButton(H, 0, [[0xFFFFFF, 0,, 4, 0xCCCCCC, 2], [0xE6E6E6], [0xCCCCCC], [0xFFFFFF,, 0xCCCCCC]]*)
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
AoEIIAIO.AddText('ym w300 Center', 'General options:').SetFont('Bold')
GeneralOptions := AoEIIAIO.AddListView('r4 -Hdr Checked -E0x200 wp', [' ', ' '])
For Option in StrSplit(IniRead('DB\001\general.ini', 'General',, ''), '`n') {
	OptionValue := StrSplit(Option, '=')
	CurrentValue := RegRead(RegKey, RegName, 0)
	GeneralOptions.Add(CurrentValue = OptionValue[2] ? 'Check' : '', IniRead('DB\001\general.ini', 'Description', OptionValue[1], ''), OptionValue[1])
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
WaterAni := AoEIIAIO.AddCheckBox('xp+4 yp+80 ' (RegRead(RegKey, 'WaterAnnimation', 0) ? 'Checked' : '') , 'Water animation')
WaterAni.OnEvent('Click', UpdateAoe2PatchWA)
UpdateAoe2PatchWA(Ctrl, Info) {
	RegWrite(Ctrl.Value, 'REG_DWORD', RegKey, 'WaterAnnimation')
}
AoEIIAIO.AddText('xp-4 yp+30 w300 Center', 'Window mod options:').SetFont('Bold')
AdvanceOptions := AoEIIAIO.AddListView('r6 -Hdr Checked -E0x200 wp', [' '])
For Option in StrSplit(IniRead('DB\001\wndmode.ini', 'WINDOWMODE',, ''), '`n') {
	OptionValue := StrSplit(Option, '=')
	AdvanceOptions.Add(OptionValue[2] ? 'Check' : '', OptionValue[1])
	AdvanceOptions.ModifyCol(1, 'AutoHdr')
}
AdvanceOptions.OnEvent('ItemCheck', UpdateWndMod)
UpdateWndMod(Ctrl, Item, Checked) {
	CurrentKey := AdvanceOptions.GetText(Item)
	IniWrite(Checked, 'DB\001\wndmode.ini', 'WINDOWMODE', CurrentKey)
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
        CloseGame()
        CleansUp()
        DefaultPB(Features['Fixs'])
        EnableControls(Features['Fixs'], 0)
        DirCopy('DB\001\' Ctrl.Text, GameDirectory, 1)
        If Ctrl.Text ~= 'v3|v4' {
            RegWrite('RUNASADMIN WINXPSP3', 'REG_SZ', RegKey, GameDirectory '\empires2.exe')
            RegWrite('RUNASADMIN WINXPSP3', 'REG_SZ', RegKey, GameDirectory '\age2_x1\age2_x1.exe')
        }
        EnableControls(Features['Fixs'])
        AnalyzeFix()
        SoundPlay('DB\000\30 Wololo.mp3')
    } Catch Error As Err {
        MsgBox("Patch failed!`n`n" Err.Message '`n' Err.Line '`n' Err.File, 'Fix', 0x10)
    }
}
AnalyzeFix() {
    MatchFix := ''
    Loop Files, 'DB\001\*', 'D' {
        Fix := A_LoopFileName
        Match := True
        Loop Files, 'DB\001\' Fix '\*.*', 'R' {
            PathFile := StrReplace(A_LoopFileDir '\' A_LoopFileName, 'DB\001\' Fix '\')
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
        CreateImageButton(GameFix['FIXHandle'][MatchFix], 0, [[0x008000,, 0xFFFFFF, 4, 0x008000, 2],,, [0xFFFFFF,, 0xCCCCCC]]*)
        GameFix['FIXHandle'][MatchFix].Redraw()
    }
}
; Cleans up
CleansUp() {
    Loop Files, 'DB\001\*', 'D' {
        Fix := A_LoopFileName
        Loop Files, 'DB\001\' Fix '\*.*', 'R' {
            PathFile := StrReplace(A_LoopFileDir '\' A_LoopFileName, 'DB\001\' Fix '\')
            If FileExist(GameDirectory '\' PathFile) {
                FileDelete(GameDirectory '\' PathFile)
            }
        }
    }
}