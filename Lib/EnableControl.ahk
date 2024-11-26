EnableControls(Controls, Enable := 1) {
    If Enable {
        For Each, Control in Controls {
            Control.Enabled := True
        }
    } Else {
        For Each, Control in Controls {
            Control.Enabled := False
        }
    }
}