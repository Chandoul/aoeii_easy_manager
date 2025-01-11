DownloadPackage(Link, Package, Clean := 0) {
    If Clean && FileExist(Package)
        FileDelete(Package)
    SplitPath(Package,, &OutDir)
    If OutDir && !DirExist(OutDir)
        DirCreate(OutDir)
    If !FileExist(Package)
        Download(Link, Package)
    If Package ~= '7z\.001$' {
        Buff := FileRead(Package, 'RAW m2')
        Hdr := StrGet(Buff,, 'CP0')
        If Hdr != '7z'
            Return False
    }
    Return True
}
DownloadPackages(Packages, Clean := 0) {
    For Link in Packages {
        If !InStr(Link, 'https://')
            Continue
        If !DownloadPackage(Link, Packages[A_Index + 1], Clean)
            Return False
    }
    Return True
}