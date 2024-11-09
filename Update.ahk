If !FileExist('7zr.exe') {
    Download('https://www.7-zip.org/a/7zr.exe', '7zr.exe')
}
If FileExist('data\Base.7z') {
    FileDelete('data\Base.7z')
}
RunWaitA([A_ComSpec ' /c 7zr.exe a -mx9 data\Base.7z app\*.* > 7zr_base.txt'])
RunWaitA(Command) {
    Error := {0	: 'No error'
            , 1	: 'Warning (Non fatal error(s)). For example, one or more files were locked by some other application, so they were not compressed'
            , 2	: 'Fatal error'
            , 7	: 'Command line error'
            , 8	: 'Not enough memory for operation'
            , 255 : 'User stopped the process'}
    Code := RunWait(Command*)
    If Code {
        MsgBox(Error.%Code%, '7z Error', 0x10)
    }
}