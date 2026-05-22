namespace eval ui::window {}

proc ui::window::createMainWindow {} {

    wm title . "Fanout Visualizer"
    wm geometry . 1400x900
    wm minsize . 1000 700

    #
    # Root Layout
    #

    frame .root -bg "#1e1e1e"
    pack .root -fill both -expand 1

    #
    # Sidebar
    #

    frame .root.sidebar \
        -bg "#252526" \
        -width 280

    pack .root.sidebar \
        -side left \
        -fill y

    pack propagate .root.sidebar 0

    #
    # Canvas Area
    #

    frame .root.workspace \
        -bg "#1e1e1e"

    pack .root.workspace \
        -side right \
        -fill both \
        -expand 1

    #
    # Canvas
    #

    set canvas [canvas .root.workspace.c \
        -bg "#1e1e1e" \
        -highlightthickness 0]

    pack .root.workspace.c \
        -fill both \
        -expand 1

    #
    # Background click catcher
    #

    $canvas create rectangle \
        0 0 5000 5000 \
        -fill "" \
        -outline "" \
        -tags background

    #
    # Status Bar
    #

    label .status \
        -text "Ready" \
        -anchor w \
        -bg "#222" \
        -fg "#d4d4d4" \
        -padx 10

    pack .status \
        -side bottom \
        -fill x

    set ::statusLabel .status

    #
    # Sidebar Title
    #

    label .root.sidebar.title \
        -text "Fanout Wiz" \
        -bg "#252526" \
        -fg white \
        -font {Helvetica 18 bold}

    pack .root.sidebar.title \
        -anchor w \
        -padx 16 \
        -pady {16 20}

    #
    # Mode Indicator
    #

    frame .root.sidebar.modeFrame \
        -bg "#252526"

    pack .root.sidebar.modeFrame \
        -fill x \
        -padx 16 \
        -pady {0 20}

    label .root.sidebar.modeLabel \
        -text "MODE" \
        -bg "#252526" \
        -fg "#888"

    label .root.sidebar.modeValue \
        -text "EDIT" \
        -bg "#252526" \
        -fg "#4cc2ff" \
        -font {Helvetica 12 bold}

    pack .root.sidebar.modeLabel \
        -anchor w

    pack .root.sidebar.modeValue \
        -anchor w

    set ::modeLabel .root.sidebar.modeValue

    #
    # BGA Geometry Section
    #

    frame .root.sidebar.geometry \
        -bg "#2d2d30"

    pack .root.sidebar.geometry \
        -fill x \
        -padx 12 \
        -pady 8

    label .root.sidebar.geometry.title \
        -text "BGA Geometry" \
        -bg "#2d2d30" \
        -fg white \
        -font {Helvetica 11 bold}

    pack .root.sidebar.geometry.title \
        -anchor w \
        -padx 12 \
        -pady {10 16}

    #
    # Rows Control
    #

    frame .root.sidebar.geometry.rows \
        -bg "#2d2d30"

    pack .root.sidebar.geometry.rows \
        -fill x \
        -padx 12 \
        -pady 6

    label .root.sidebar.geometry.rows.label \
        -text "Rows" \
        -bg "#2d2d30" \
        -fg "#cccccc"

    label .root.sidebar.geometry.rows.value \
        -text "10" \
        -bg "#2d2d30" \
        -fg "#4cc2ff"

    scale .root.sidebar.geometry.rows.slider \
        -from 2 \
        -to 32 \
        -orient horizontal \
        -showvalue 0 \
        -length 180 \
        -bg "#2d2d30" \
        -fg white \
        -troughcolor "#3c3c3c" \
        -activebackground "#4cc2ff" \
        -highlightthickness 0 \
        -borderwidth 0

    .root.sidebar.geometry.rows.slider set 10

    pack .root.sidebar.geometry.rows.label \
        -side left

    pack .root.sidebar.geometry.rows.value \
        -side right

    pack .root.sidebar.geometry.rows.slider \
        -side bottom \
        -fill x \
        -pady {6 0}

    #
    # Cols Control
    #

    frame .root.sidebar.geometry.cols \
        -bg "#2d2d30"

    pack .root.sidebar.geometry.cols \
        -fill x \
        -padx 12 \
        -pady 6

    label .root.sidebar.geometry.cols.label \
        -text "Cols" \
        -bg "#2d2d30" \
        -fg "#cccccc"

    label .root.sidebar.geometry.cols.value \
        -text "10" \
        -bg "#2d2d30" \
        -fg "#4cc2ff"

    scale .root.sidebar.geometry.cols.slider \
        -from 2 \
        -to 32 \
        -orient horizontal \
        -showvalue 0 \
        -length 180 \
        -bg "#2d2d30" \
        -fg white \
        -troughcolor "#3c3c3c" \
        -activebackground "#4cc2ff" \
        -highlightthickness 0 \
        -borderwidth 0

    .root.sidebar.geometry.cols.slider set 10

    pack .root.sidebar.geometry.cols.label \
        -side left

    pack .root.sidebar.geometry.cols.value \
        -side right

    pack .root.sidebar.geometry.cols.slider \
        -side bottom \
        -fill x \
        -pady {6 0}

    #
    # Slider Value Updates
    #

    bind .root.sidebar.geometry.rows.slider <Motion> {
        .root.sidebar.geometry.rows.value configure \
            -text [.root.sidebar.geometry.rows.slider get]
    }

    bind .root.sidebar.geometry.cols.slider <Motion> {
        .root.sidebar.geometry.cols.value configure \
            -text [.root.sidebar.geometry.cols.slider get]
    }

    #
    # Apply Button
    #

    button .root.sidebar.apply \
        -text "Apply Changes" \
        -bg "#4cc2ff" \
        -fg black \
        -activebackground "#66d9ff" \
        -activeforeground black \
        -relief flat \
        -borderwidth 0 \
        -padx 10 \
        -pady 10 \
        -command controller::applyAndEnableSelection

    pack .root.sidebar.apply \
        -fill x \
        -padx 16 \
        -pady {20 10}

    return .root.workspace.c
}