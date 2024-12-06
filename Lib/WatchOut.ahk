SetTimer(WatchOut, 1000)
WatchOut() {
    If WinExist('ahk_exe voobly.exe')
        ExitApp()
}