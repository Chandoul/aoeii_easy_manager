FixExist(Fix, WorkDir) {
        Match := True
        Loop Files, 'DB\Fix\' Fix '\*.*', 'R' {
            PathFile := StrReplace(A_LoopFileDir '\' A_LoopFileName, 'DB\Fix\' Fix '\')
            If !FileExist(WorkDir '\' PathFile) && Match {
                Match := False
                Break
            }
            CurrentHash := HashFile(A_LoopFileFullPath)
            FoundHash := HashFile(WorkDir '\' PathFile)
            If (CurrentHash != FoundHash) && Match {
                Match := False
                Break
            }
        }
    Return Match
}