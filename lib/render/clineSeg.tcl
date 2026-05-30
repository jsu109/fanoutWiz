namespace eval render::clineSeg {}

proc render::clineSeg::drawClineSegs {canvas frame} {
    
    # -----------------------------
    # styling defaults
    # -----------------------------
    set color "#035efc"
    set width [units::mm 0.1]

    if {[dict exists $frame color]} {
        set color [dict get $frame color]
    }

    if {[dict exists $frame width]} {
        set width [dict get $frame width]
    }

    set segs [dict get $frame segs]
    
    # -----------------------------
    # view transform
    # -----------------------------
    set scale 1.0
    set ox 0
    set oy 0

    if {[info exists ::view::scale]} {
        set scale $::view::scale
    }

    if {[info exists ::view::offsetX]} {
        set ox $::view::offsetX
    }

    if {[info exists ::view::offsetY]} {
        set oy $::view::offsetY
    }

    dict for {padId padClines} $segs {
        set segments [dict get $padClines segments]

        dict for {segName segment} $segments {
            set geom [dict get $segment geometry]

            set x1 [dict get $geom x1]
            set y1 [dict get $geom y1]
            set x2 [dict get $geom x2]
            set y2 [dict get $geom y2]

            # -----------------------------
            # transform
            # -----------------------------
            set x1 [expr {$x1 * $scale + $ox}]
            set y1 [expr {$y1 * $scale + $oy}]
            set x2 [expr {$x2 * $scale + $ox}]
            set y2 [expr {$y2 * $scale + $oy}]

            # -----------------------------
            # draw
            # -----------------------------
            set segWidth [expr {[dict get $segment width] * $scale}]

            $canvas create line \
                $x1 $y1 $x2 $y2 \
                -fill $color \
                -width $segWidth
        }
    }
}
