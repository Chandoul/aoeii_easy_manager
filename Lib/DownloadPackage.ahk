DownloadPackage(Link, Package, Clean := 0, DG := 0, Part := 0, Parts := 0) {
    If Clean && FileExist(Package)
        FileDelete(Package)
    SplitPath(Package, , &OutDir)
    If OutDir && !DirExist(OutDir)
        DirCreate(OutDir)
    If !FileExist(Package) {
        DG['LT'].Value := Link
        DG['PB'].Value := 0
        SetTimer(UpdateDG, 1000)
        FileSize := GetFileSize(Link)
        Download(Link, Package)
        SetTimer(UpdateDG, 0)
        UpdateDG() {
            If FileSize {
                CurrentSize := FileExist(Package) ? FileGetSize(Package) : 0
                Progress := Round(CurrentSize / FileSize * 100)
                DG['PT'].Value := 'Downloading package ... ( ' Progress ' % ) - ' Part ' / ' Parts
                DG['PB'].Value := Progress
            } Else {
                DG['PT'].Value := 'Downloading package ... - ' Part ' / ' Parts
            }
        }
    }
    If Package ~= '7z\.001$' {
        Buff := FileRead(Package, 'RAW m2')
        Hdr := StrGet(Buff, , 'CP0')
        If Hdr != '7z'
            Return False
    }
    Return True
}
DownloadPackages(Packages, Clean := 0) {
    DG := DownloadGui()
    DG.Show()
    Part := 0
    For Link in Packages {
        If !InStr(Link, 'https://')
            Continue
                ++Part
        If !DownloadPackage(Link, Packages[A_Index + 1], Clean, DG, Part, Packages.Length // 2) {
            DG.Hide()
            Return False
        }
    }
    DG.Hide()
    Return True
}

GetFileSize(Link) {
    Try {
        WebRequest := ComObject("WinHttp.WinHttpRequest.5.1")
        WebRequest.Open("HEAD", Link)
        WebRequest.Send()
        Return ByteSize := WebRequest.GetResponseHeader("Content-Length")
    } Catch
        Return 0
}

DownloadGui() {
    Static DG := 0
    If !DG {
        DG := Gui('-SysMenu', 'EM Downloader')
        DG.BackColor := 'White'
        DG.SetFont('s10', 'Segoe UI')
        PT := DG.AddEdit('w300 Center ReadOnly -E0X200 BackgroundWhite vPT')
        PT.SetFont('Bold')
        PB := DG.AddProgress('w300 h18 vPB')
        DG.SetFont('s8')
        LT := DG.AddEdit('w300 Center ReadOnly -E0X200 BackgroundWhite cblue vLT')
    }
    Return DG
}