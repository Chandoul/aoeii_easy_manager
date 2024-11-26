Prepare(Hide := False) {
    Static ON := 0, Gif := 0, P := 0
    If ON := !ON {
        P := Gui('-MinimizeBox', 'Preparing...')
        P.BackColor := 'White'
        P.MarginX := 10
        P.MarginY := 10
        P.OnEvent('Close', (*) => ExitApp())
        P.SetFont('s8 Bold Italic', 'Segoe UI')
        Tasks := P.AddListBox('cGreen w200 r10')
        If !Hide
            P.Show()
        Return Tasks
    } Else {
        P.Destroy()
    }
}