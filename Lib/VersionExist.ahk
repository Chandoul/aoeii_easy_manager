VersionExist(Edition, Version, GameDir) {
    Match := True
    Loop Files, 'DB\Version\' Edition '\' Version '\*.*', 'R' {
        PathFile := StrReplace(A_LoopFileDir '\' A_LoopFileName, 'DB\Version\' Edition '\' Version '\')
        If !FileExist(GameDir '\' PathFile) && Match {
            Match := False
            Break
        }
        CurrentHash := HashFile(A_LoopFileFullPath)
        FoundHash := HashFile(GameDir '\' PathFile)
        If (CurrentHash != FoundHash) && Match {
            Match := False
            Break
        }
    }
    Return Match
}