If !FileExist('7zr.exe') {
    Download('https://www.7-zip.org/a/7zr.exe', '7zr.exe')
}
If FileExist('data\Base.7z') {
    FileDelete('data\Base.7z')
}
RunWait(A_ComSpec ' /c 7zr.exe a -mx9 data\Base.7z app\*.* > 7zr_base.txt')