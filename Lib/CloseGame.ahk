CloseGame() {
    For Each, App in ['empires2.exe', 'age2_x1.exe', 'age2_x2.exe'] {
        If ProcessExist(App) {
            Try {
                ProcessClose(App)
                ProcessWaitClose(App, 5)
            } Catch Error As Err {
                MsgBox("Game close failed!`n`n" Err.Message '`n' Err.Line '`n' Err.File, 'Fix', 0x10)
            }
        }
    }
}