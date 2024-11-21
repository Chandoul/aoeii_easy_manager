; Returns a folder size in KB
FolderGetSize(Location) {
    Size := 0
    Loop Files, Location '\*.*', 'R' {
        Size += FileGetSize(A_LoopFileFullPath, 'K')
    }
    Return Size
}