WatchFileSize(Path := '', Ctrl := '') {
    Size := FileGetSize(Path, 'K')
    Size := Round(Size / 1024, 2)
    Ctrl.Text := '↓ ' Size ' MB'
    CreateImageButton(Ctrl, 0, IBBlue*)
}