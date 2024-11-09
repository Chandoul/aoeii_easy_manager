#Include SharedLib.ahk
GameLanguage := Map()
Features['Language'] := []
AoEIIAIO.Title := 'GAME INTERFACE LANGUAGES'
Index := 0
Loop Files, 'DB\006\*', 'D' {
    If (A_LoopFileName = 'Restore') {
        Continue
    }
    ++Index
    H := AoEIIAIO.AddButton('w200' (Mod(Index, 6) = 1 ? ' ym' : ''), A_LoopFileName)
    H.SetFont('Bold s11')
    CreateImageButton(H, 0, [[0xFFFFFF,,, 4, 0xCCCCCC, 2], [0xE6E6E6], [0xCCCCCC], [0xFFFFFF,, 0xCCCCCC]]*)
    Features['Language'].Push(H)
    H.OnEvent('Click', ApplyLanguage)
    GameLanguage[A_LoopFileName] := H
}
H := AoEIIAIO.AddButton('xm w200', 'Restore')
H.SetFont('Bold s11')
CreateImageButton(H, 0, [[0x00A200,, 0xFFFFFF, 4, 0x008200, 2], [0x009000], [0x008200], [0xFFFFFF,, 0xCCCCCC]]*)
Features['Language'].Push(H)
H.OnEvent('Click', ApplyLanguage)
GameLanguage['Restore'] := H
AoEIIAIO.Show()
GameDirectory := IniRead(Config, 'Settings', 'GameDirectory', '')
If !ValidGameDirectory(GameDirectory) {
    For Each, Version in Features['Language'] {
        Version.Enabled := False
    }
    If 'Yes' = MsgBox('Game is not yet located!, want to select now?', 'Game', 0x4 + 0x40) {
        Run('Game.ahk')
    }
    ExitApp()
}
AnalyzeLanguage(1)
; Aanalyzes game languages
AnalyzeLanguage(Backup := 0) {
    If Backup {
        If !DirExist('DB\006\Restore') {
            DirCreate('DB\006\Restore')
            Loop Files, 'DB\006\*', 'D' {
                Language := A_LoopFileName
                Loop Files, 'DB\006\' Language '\*.*', 'R' {
                    PathFile := StrReplace(A_LoopFileDir '\' A_LoopFileName, 'DB\006\' Language '\')
                    If FileExist(GameDirectory '\' PathFile) {
                        SplitPath('DB\006\Restore\' PathFile, &OutFileName, &OutDir)
                        If !DirExist(OutDir) {
                            DirCreate(OutDir)
                        }
                        If !FileExist(OutDir '\' OutFileName)
                            FileCopy(GameDirectory '\' PathFile, OutDir '\' OutFileName)
                    }
                }
            }
        }
    }
    MatchLanguage := ''
    Loop Files, 'DB\006\*', 'D' {
        Language := A_LoopFileName
        Match := True
        Loop Files, 'DB\006\' Language '\*.*', 'R' {
            PathFile := StrReplace(A_LoopFileDir '\' A_LoopFileName, 'DB\006\' Language '\')
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
            CreateImageButton(GameLanguage[MatchLanguage], 0, [[0x00A200,, 0xFFFFFF, 4, 0x008200, 2], [0x009000], [0x008200], [0xFFFFFF,, 0xCCCCCC]]*)
            GameLanguage[MatchLanguage].Redraw()
        }
    }
}
CleanUp() {
    Loop Files, 'DB\006\*', 'D' {
        Language := A_LoopFileName
        Loop Files, 'DB\006\' Language '\*.*', 'R' {
            PathFile := StrReplace(A_LoopFileDir '\' A_LoopFileName, 'DB\006\' Language '\')
            If FileExist(GameDirectory '\' PathFile) {
                FileDelete(GameDirectory '\' PathFile)
            }
        }
    }
}
ApplyLanguage(Ctrl, Info) {
    Try {
        DefaultPB(Features['Language'])
        EnableControls(Features['Language'], 0)
        CloseGame()
        CleanUp()
        If Ctrl.Text = 'Restore' {
            DirCopy('DB\006\Restore', GameDirectory, 1)
        } Else {
            DirCopy('DB\006\' Ctrl.Text, GameDirectory, 1)
        }
        AnalyzeLanguage()
        EnableControls(Features['Language'])
        SoundPlay('DB\000\30 Wololo.mp3')
    } Catch Error As Err {
        MsgBox("Language set failed!`n`n" Err.Message '`n' Err.Line '`n' Err.File, 'Language', 0x10)
    }
}