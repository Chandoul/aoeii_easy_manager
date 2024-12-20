DownloadPackage(Link, Package, Clean := 0) {
    If Clean && FileExist(Package)
        FileDelete(Package)
    SplitPath(Package,, &OutDir)
    If OutDir && !DirExist(OutDir)
        DirCreate(OutDir)
    If !FileExist(Package)
        Download(Link, Package)
}
DownloadPackages(Packages, Clean := 0) {
    For Link in Packages {
        If !InStr(Link, 'https://')
            Continue
        DownloadPackage(Link, Packages[A_Index + 1], Clean)
    }
}