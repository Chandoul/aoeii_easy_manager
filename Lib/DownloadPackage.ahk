; Downloads a given package
DownloadPackage(Link, Package) {
    If !FileExist(Package) {
        Msgbox Package
        Download(Link, Package)
    }
}