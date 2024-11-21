; Extracts a given package
ExtractPackage(Package, Folder, Clean := 0) {
    If Clean && DirExist(Folder) {
        DirDelete(Folder, 1)
    }
    RunWait('DB\7za.exe x ' Package ' -o"' Folder '" -aoa')
}