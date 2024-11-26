DMBackup(GameDirectory, ModBackup := 'tmp\Backup', ModeName := '', Flag := 0) {
    Switch Flag {
        Case 0:
            If DirExist(ModBackup) {
                If 'Yes' = MsgBox('A data mod backup was found, it is recommended to restore it first before you continue.`n`nRestore it now?', 'Backup', 0x4 + 0x30)
                    DirCopy(ModBackup, GameDirectory, 1), DirDelete(ModBackup, 1)
            }
        Case 1:
        If DirExist(ModBackup) {
            DirCopy(ModBackup, GameDirectory, 1), DirDelete(ModBackup, 1)
        }
        Case 2:
            If !DirExist(ModBackup)
                DirCreate(ModBackup)
            Loop Files 'tmp\' ModeName '\*.*', 'R' {
                FilePath := FullPathRightTrim(A_LoopFileFullPath, ModeName)
                If !FileExist(GameDirectory '\' FilePath)
                    Continue
                SplitPath(FilePath,, &OutDir)
                If OutDir != '' && !DirExist(ModBackup '\' OutDir)
                    DirCreate(ModBackup '\' OutDir)
                FileCopy(GameDirectory '\' FilePath, ModBackup '\' FilePath, 1)
            }
    }
    FullPathRightTrim(Path, SplitFolder) {
        Path := StrSplit(Path, '\')
        NewPath := ''
        For Part in Path {
            If Part = SplitFolder {
                NewPath .= '\'
            } Else If NewPath != '' {
                NewPath .= '\' Part
            }
        }
        Return Trim(NewPath, '\\')
    }
}