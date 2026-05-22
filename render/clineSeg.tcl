namespace eval render::clineSeg {}

proc render::clineSeg::drawClineSegs {canvas segs segDef} {

    # Optional styling (safe defaults)
    set color "#00ffcc"
    set width 2

    if {[dict exists $segDef color]} {
        set color [dict get $segDef color]
    }

    if {[dict exists $segDef width]} {
        set width [dict get $segDef width]
    }

    dict for {segName segData} $segs {

        # Extract geometry safely
        if {![dict exists $segData geometry]} {
            continue
        }

        set geom [dict get $segData geometry]

        set x1 [dict get $geom x1]
        set y1 [dict get $geom y1]
        set x2 [dict get $geom x2]
        set y2 [dict get $geom y2]

        # -------------------------------------------------
        # VIEW TRANSFORM (world -> canvas)
        # -------------------------------------------------
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
        set drawWidth [expr {$width * $scale}]
        set x1 [expr {$x1 * $scale + $ox}]
        set y1 [expr {$y1 * $scale + $oy}]
        set x2 [expr {$x2 * $scale + $ox}]
        set y2 [expr {$y2 * $scale + $oy}]
        puts $segData
        # Draw segment line
        $canvas create line \
            $x1 $y1 $x2 $y2 \
            -fill $color \
            -width $drawWidth
    }
}