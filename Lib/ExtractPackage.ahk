; Extracts a given package
ExtractPackage(Package, Folder, Clean := False, Hide := False, OverWrite := False) {
    If Clean && DirExist(Folder)
        DirDelete(Folder, 1)
    If OverWrite || !DirExist(Folder)
        RunWait('DB\7za.exe x ' Package ' -o"' Folder '" -aoa',, Hide ? 'Hide' : '')
}