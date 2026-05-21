namespace eval ui::window {}
    proc ui::window::createMainWindow {} {

    wm title . "Fanout Visualizer"

    set canvas [canvas .c \
        -width 1200 \
        -height 800 \
        -bg "#1e1e1e"]

    $canvas create rectangle 0 0 5000 5000 \
        -fill "" \
        -outline "" \
        -tags background

    pack .c -fill both -expand 1
    
    label .status -text "Ready" -anchor w -bg "#222" -fg white
    pack .status -fill x -side bottom
    set ::statusLabel .status

    frame .controls
    place .controls -relx 0.02 -rely 0.02

    label .controls.l1 -text "Rows" -bg "#222" -fg white
    scale .controls.rows \
        -from 2 -to 32 \
        -orient horizontal \
        -length 200 \
        -bg "#222" \
        -fg white \
        -troughcolor "#444"

    .controls.rows set 10

    label .controls.l2 -text "Cols" -bg "#222" -fg white
    scale .controls.cols \
        -from 2 -to 32 \
        -orient horizontal \
        -length 200 \
        -bg "#222" \
        -fg white \
        -troughcolor "#444"

    .controls.cols set 10

    pack .controls.l1 .controls.rows \
    .controls.l2 .controls.cols \
    -side top -anchor w

    bind .controls.rows <Motion> {controller::applyBGA}
    bind .controls.cols <Motion> {controller::applyBGA}
    
    button .controls.apply -text "Apply BGA" \
    -bg "#4cc2ff" \
    -fg black \
    -activebackground "#66d9ff" \
    -command controller::applyAndEnableSelection

    pack .controls.apply -side top -fill x -pady 6
    return .c
    }

