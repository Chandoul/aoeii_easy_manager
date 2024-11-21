; Checks if a directory contains the game
ValidGameDirectory(Location) {
    Return FileExist(Location '\empires2.exe')
    &&     FileExist(Location '\language.dll')
    &&     FileExist(Location '\Data\graphics.drs')
    &&     FileExist(Location '\Data\interfac.drs')
    &&     FileExist(Location '\Data\terrain.drs') ? 1 : 0
}