#Requires AutoHotkey v2
#SingleInstance Force

#Include <WatchOut>
#Include <ImageButton>
#Include <ReadWriteJSON>
#Include <ValidGame>
#Include <LockCheck>
#Include <HashFile>
#Include <DownloadPackage>
#Include <ExtractPackage>
#Include <IBButtons>
#Include <FixExist>

GameVersion := ReadSetting(, 'RequireVersion')
GameDirectory := ReadSetting('Setting.json', 'GameLocation', '')
VersionPackage := ReadSetting(, 'VersionPackage')

AoEIIAIO := Gui(, 'GAME VERSION')
AoEIIAIO.BackColor := 'White'
AoEIIAIO.OnEvent('Close', (*) => ExitApp())
AoEIIAIO.MarginX := AoEIIAIO.MarginY := 10
AoEIIAIO.SetFont('s10 Bold', 'Calibri')

H := AoEIIAIO.AddText('cRed w150 Center h30', 'The Age of Kings')
H.SetFont('Bold s12')
H := AoEIIAIO.AddPicture('xp+59 yp+30', 'DB\Base\aok.png')
H.OnEvent('Click', LaunchGame)
AoEIIAIO.AddText('xp-59 yp+35 w1 h1')
Features := Map(), Features['Version'] := []
GameVersion['aok'] := Map()
Loop Files, 'DB\Version\aok\*', 'D' {
    H := AoEIIAIO.AddButton('w150', AOK := A_LoopFileName)
    H.SetFont('Bold')
    CreateImageButton(H, 0, IBRed*)
    H.OnEvent('Click', ApplyVersion)
    GameVersion['aok'][H] := 1
    Features['Version'].Push(H)
}

H := AoEIIAIO.AddText('cBlue ym w150 Center h30', 'The Conquerors')
H.SetFont('Bold s12')
H := AoEIIAIO.AddPicture('xp+59 yp+30', 'DB\Base\aoc.png')
H.OnEvent('Click', LaunchGame)
AoEIIAIO.AddText('xp-59 yp+35 w1 h1')
GameVersion['aoc'] := Map()
Loop Files, 'DB\Version\aoc\*', 'D' {
    H := AoEIIAIO.AddButton('w150', AOC := A_LoopFileName)
    H.SetFont('Bold')
    CreateImageButton(H, 0, IBBlue1*)
    H.OnEvent('Click', ApplyVersion)
    GameVersion['aoc'][H] := 2
    Features['Version'].Push(H)
}

H := AoEIIAIO.AddText('cGreen ym w150 Center h30', 'Forgotten Empires')
H.SetFont('Bold s12')
H := AoEIIAIO.AddPicture('xp+59 yp+30', 'DB\Base\fe.png')
H.OnEvent('Click', LaunchGame)
AoEIIAIO.AddText('xp-59 yp+35 w1 h1')
GameVersion['fe'] := Map()
Loop Files, 'DB\Version\fe\*', 'D' {
    H := AoEIIAIO.AddButton('w150', FE := A_LoopFileName)
    H.SetFont('Bold')
    CreateImageButton(H, 0, IBGreen*)
    H.OnEvent('Click', ApplyVersion)
    GameVersion['fe'][H] := 3
    Features['Version'].Push(H)
}

AoEIIAIO.Show()

If A_Args.Length {
    Switch A_Args[1] {
        Case '1.0':
            For H in GameVersion['aoc'] {
                If H.Text = '1.0' {
                    ApplyVersion(H, '')
                    SetTimer(Quit, -1000)
                    MsgBox('Version applied successfully!', 'Version', 0x40)
                    Quit() {
                        ExitApp()
                    }
                }
            }
    }
}

AnalyzeVersion()
If !ValidGameDirectory(GameDirectory) {
    For Each, Fix in Features['Version']
        Fix.Enabled := False
    If 'Yes' = MsgBox('Game is not yet located!, want to select now?', 'Game', 0x4 + 0x40)
        Run('Game.ahk')
    ExitApp()
}

FindGame(Ctrl) {
    FGame := ''
    If GameVersion['aok'].Has(Ctrl) {
        FGame := 'aok'
    }
    If GameVersion['aoc'].Has(Ctrl) {
        FGame := 'aoc'
    }
    If GameVersion['fe'].Has(Ctrl) {
        FGame := 'fe'
    }
    Return FGame
}

CleansUp(FGame) {
    Loop Files, 'DB\Version\' FGame '\*', 'D' {
        Version := A_LoopFileName
        Loop Files, 'DB\Version\' FGame '\' Version '\*.*', 'R' {
            PathFile := StrReplace(A_LoopFileDir '\' A_LoopFileName, 'DB\Version\' FGame '\' Version '\')
            If FileExist(GameDirectory '\' PathFile) {
                FileDelete(GameDirectory '\' PathFile)
            }
        }
    }
}

ApplyReqVersion(Ctrl, FGame) {
    If GameVersion.Has(FGame 'Combine')
        && GameVersion[FGame 'Combine'].Has(Ctrl.Text) {
            If DirExist('DB\Version\' FGame '\' GameVersion[FGame 'Combine'][Ctrl.Text]) {
                DirCopy('DB\Version\' FGame '\' GameVersion[FGame 'Combine'][Ctrl.Text], GameDirectory, 1)
            }
    }
    If DirExist('DB\Version\' FGame '\' Ctrl.Text) {
        DirCopy('DB\Version\' FGame '\' Ctrl.Text, GameDirectory, 1)
    }
}
ApplyVersion(Ctrl, Info) {
    If FixExist('Fix v1', GameDirectory)
        || FixExist('Fix v2', GameDirectory)
        || FixExist('Fix v3', GameDirectory)
        || FixExist('Fix v4', GameDirectory) {
            If Ctrl.Text ~= '1\.0e|1\.1' {
                Msgbox('Sorry to inform you that ' Ctrl.Text ' is not compatible with the fixs (Fix v1, v2, v3, v4, v5)', 'Incompatible!', 0x30)
                Return
            }
    }
    Try {
        DisableOptions(FGame := FindGame(Ctrl))
        CleansUp(FGame)
        ApplyReqVersion(Ctrl, FGame)
        AnalyzeVersion()
        SoundPlay('DB\Base\30 Wololo.mp3')
        EnableOptions(FGame)

        If FixExist('Fix v5', GameDirectory) {
            If FileExist(GameDirectory '\wndmode.dll')
                FileDelete(GameDirectory '\wndmode.dll')
            If FileExist(GameDirectory '\age2_x1\wndmode.dll')
                FileDelete(GameDirectory '\age2_x1\wndmode.dll')
            Return
        }
    } Catch {
        If !LockCheck(GameDirectory) {
            EnableOptions(FGame)
            AnalyzeVersion()
            Return
        }
        ApplyVersion(Ctrl, Info)
    }
}
; Enables a versions list
EnableOptions(Game) {
    For Item in GameVersion[Game] {
        Item.Enabled := True
    }
}
; Disables a versions list
DisableOptions(Game) {
    Switch Game {
        Case 'aok': IB := IBRed
        Case 'aoc': IB := IBBlue1
        Case 'fe': IB := IBGreen
    }
    For Item in GameVersion[Game] {
        Item.Enabled := False
        CreateImageButton(Item, 0, IB*)
    }
}
; Return a game version based on the available versions
AppliedVersionLookUp(Location) {
    MatchVersion := ''
    Loop Files, 'DB\Version\' Location '\*', 'D' {
        Version := A_LoopFileName
        Match := True
        Loop Files, 'DB\Version\' Location '\' Version '\*.*', 'R' {
            PathFile := StrReplace(A_LoopFileDir '\' A_LoopFileName, 'DB\Version\' Location '\' Version '\')
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
            MatchVersion := Version
        }
    }
    If MatchVersion {
        For Control in GameVersion[Location] {
            If Control.Text = MatchVersion {
                Return [MatchVersion, Control]
            }
        }
    }
    Return ''
}
; Analyzes game versions
AnalyzeVersion() {
    If FileExist(GameDirectory '\empires2.exe') {
        Version := AppliedVersionLookUp('aok')
        If Type(Version) = 'Array' {
            For Game, Version in GameVersion['aok'] {
                Game.Enabled := True
            }
            CreateImageButton(Version[2], 0, IBRed1*)
        }
    }
    If FileExist(GameDirectory '\age2_x1\age2_x1.exe') {
        Version := AppliedVersionLookUp('aoc')
        If Type(Version) = 'Array' {
            For Game, Version in GameVersion['aoc'] {
                Game.Enabled := True
            }
            CreateImageButton(Version[2], 0, IBBlue2*)
        }
    }
    If FileExist(GameDirectory '\age2_x1\age2_x2.exe') {
        Version := AppliedVersionLookUp('fe')
        If Type(Version) = 'Array' {
            For Game, Version in GameVersion['fe'] {
                Game.Enabled := True
            }
            CreateImageButton(Version[2], 0, IBGreen1*)
        }
    }
}
LaunchGame(Ctrl, Info) {
    If InStr(Ctrl.Value, 'aok') && FileExist(GameDirectory '\empires2.exe') {
        Run(GameDirectory '\empires2.exe', GameDirectory)
    }
    If InStr(Ctrl.Value, 'aoc') && FileExist(GameDirectory '\age2_x1\age2_x1.exe') {
        Run(GameDirectory '\age2_x1\age2_x1.exe', GameDirectory)
    }
    If InStr(Ctrl.Value, 'fe') && FileExist(GameDirectory '\age2_x1\age2_x2.exe') {
        Run(GameDirectory '\age2_x1\age2_x2.exe', GameDirectory)
    }
}